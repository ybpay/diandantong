# encoding: utf-8
module Ddt
  class StatisticBase
    ALL_BRANCH = 0
    ABSTRACT_BRANCH = -1
    ALL_TIME_INTERVAL = 0
    include Ddt::StatisticHelper

    PRIORITY_QUEUE_STATISTICS = 'statistics'
    PRIORITY_QUEUE_HEAVY_STATISTICS = 'heavy_statistics'

    class << self
      def hash_attrs(hash)
        @hash_attr_hash ||= {}
        @hash_attr_hash.merge!(hash)
        @hash_attr_hash
      end
      attr_reader :hash_attr_hash

      def cache_result(&block)

        define_method :cache_record do
          @cache_key ||= self.compute_cache_key
          @cache_record ||= Ddt::StatisticsCache.where(key: @cache_key).first
        end

        define_method :cache_key do
          @cache_key ||= self.compute_cache_key
        end

        define_method :cache_state do
          self.cache_record.try(:state)
        end

        define_method :submit_async_statistics do
          options = @options.clone
          options.except!(:shop, :accessible_branches)
          options[:shop_id] = @shop.id
          options[:accessible_branch_ids] = @accessible_branches.try(:map, &:id)
          Rails.logger.info("#{self.class.name}: #{options}")
          cache = Ddt::StatisticsCache.where(key: cache_key).first_or_initialize
          cache.operator_id = options[:statistics_operator_id]
          cache.shop_id = @shop.id
          cache.name = @statistic_name
          cache.label = self.class.info[:label]
          cache.query = @cache_kv_hash.to_json
          idx1 = @request_url.index(/\.html|\.csv|\.xls/)
          idx2 = @request_url.index('?')
          cache.url = @request_url[0...idx1] + '.html' + @request_url[idx2..-1]
          cache.state = 'commit'
          cache.save!

          if @proirity_queue.present?
            proirity_queue = @proirity_queue
          elsif (@start_time.present? and @end_time.present? and @end_time - @start_time <= 31.days) and (!self.respond_to?(:branch_id) || !all_branch?)
            proirity_queue = PRIORITY_QUEUE_STATISTICS
          else
            proirity_queue = PRIORITY_QUEUE_HEAVY_STATISTICS
          end
          self.class.delay_for(5.seconds, :queue => proirity_queue).async_get_result(self.class.name, cache_key, options)
          Rails.logger.info("submit get result job for #{cache_key}")
          cache
        end

        define_method :fetch_statistics_result do
          data_url = self.cache_record.result.url
          if data_url.present?
            Rails.logger.info("return cached by mysql for #{@cache_key}")
            if self.info[:render_view]
              @result ||= Marshal::load(open(data_url))
              return block_given? ? instance_exec(@result, &block) : @result
            else
              @html ||= open(data_url).read.force_encoding('utf-8').html_safe
            end
          else
            Rails.logger.info("return cached by mysql but empty for #{@cache_key}")
            nil
          end
        end

        def async_get_result(klass, cache_key, options)
          options = options || {}
          cache = Ddt::StatisticsCache.where(key: cache_key).first
          if cache.present?
            begin
              Rails.logger.info("[sidekiq] #{klass}: #{options}")
              options[:shop] = ::Ddt::Shop.find(options[:shop_id])
              options[:accessible_branches] = ::Ddt::Branch.where(id: options[:accessible_branch_ids]) if options[:accessible_branch_ids].present?
              statistics = klass.constantize.new(options)
              statistics.instance_variable_set(:'@cache_key', cache_key)
              statistics.instance_variable_set(:'@cache_record', cache)
              statistics.async_statistics_start_at = Time.now
              basename = "#{cache.name}(#{statistics.start_time}_#{statistics.end_time})"
              csv_file = Tempfile.new([basename, '.csv'], :encoding => 'utf-8')
              xls_file = Tempfile.new([basename, '.xls'], :encoding => 'utf-8')
              begin
                # TODO: 大于5000条数据就不用显示了
                if self.info[:render_view]
                  cache.result = StringIoUploadFile.new(basename, statistics.result, true)
                else
                  cache.result = StringIoUploadFile.new(basename, statistics.to_html, false)
                end
                cache.csv = statistics.to_csv(csv_file)
                cache.xls = statistics.to_xls(xls_file)
                cache.state = 'completed'
                cache.cost_time = Time.now - statistics.async_statistics_start_at
                cache.save!
              ensure
                csv_file.close
                csv_file.unlink
                xls_file.close
                xls_file.unlink
              end
              Rails.logger.info("finish get result job for #{cache_key}")
            rescue => e
              emsg = "failed get result job for #{cache_key}"
              Rails.logger.error("#{emsg}, exception=#{e}: #{e.backtrace}")
              cache.state = 'exception'
              cache.save!
              if Rails.env.production?
                ExceptionNotifier.notify_exception(e, data: {
                    message: emsg,
                    shop_id:  options[:shop_id],
                    name: cache.name,
                    label: cache.label,
                    query: cache.query
                })
              else
                raise e
              end
            end
          else
            Rails.logger.error("cache has not persist yet for #{cache_key}")
            raise "cache has not persist yet for #{cache_key}"
          end
        end
      end
    end

    attr_accessor :statistic_name, :request_path, :shop, :accessible_branches, :page, :time_interval_id
    attr_accessor :is_async, :pr_type, :proirity_queue, :async_statistics_start_at, :on_split_query_progress

    hash_attrs({
      分类: :statistic_name,
      路径: Proc.new{@request_path.split('.')[0]},
      点账号: Proc.new{@shop.id},
      # 管理门店: Proc.new{@accessible_branches.try(:map, &:id)},
      页数: :page,
      时间区间: :time_interval_id,
      查询随机: :rand_hash
    })

    def self.default_info
      {
        expose_to_api: false,
        type: self.name.split("::")[1].gsub("Statistic", "").underscore,
        permit_params: [:name, :type, :page],
        sortable: false
      }
    end

    def self.info
      default_info.merge(self.class_info)
    end

    def initialize(options={})
      @is_async = options.fetch(:is_async, true)
      @options = options
      @statistic_name = options[:statistic_name]
      @request_path = options[:request_path]
      @request_url = options[:request_url]
      @shop = options[:shop]
      @accessible_branches = options[:accessible_branches]
      @page = options[:page]
      if options[:time_interval_id].present?
        @time_interval_id = options[:time_interval_id].to_i
        @time_interval = @shop.time_intervals.find(@time_interval_id) if @time_interval_id > 0
      end
      @rand_hash = options[:rand_hash]
      @pr_type = options[:pr_type]
      options[:start_time] = Time.parse(options[:start_time]) if options[:start_time].present? && (options[:start_time].is_a? String)
      options[:end_time] = Time.parse(options[:end_time]) if options[:end_time].present? && (options[:end_time].is_a? String)
    end

    def compute_cache_key(result_method: :result)
      klass = self.class
      cache_kv_hash = {}
      while (klass != StatisticBase)
        cache_kv_hash.merge!(klass.hash_attr_hash || {})
        klass = klass.superclass
      end
      cache_kv_hash.merge!(klass.hash_attr_hash || {})

      Rails.logger.info("cache_kv_hash=#{cache_kv_hash}")
      cache_kv_hash.keys.each do |key|
        prop = cache_kv_hash[key]
        if prop.is_a?(Symbol)
          value = instance_variable_get("@#{prop}").to_s
        else
          value = instance_eval(&prop).to_s
        end
        cache_kv_hash[key] = value
      end
      cache_kv_hash['缓存方法名'] = result_method
      hash = Digest::SHA1.hexdigest(cache_kv_hash.to_s)
      Rails.logger.info("hash=#{hash}, cache_kv_hash=#{cache_kv_hash}")
      @cache_kv_hash = cache_kv_hash.except(:管理门店, :路径, :查询随机, :缓存方法名)
      "ddt/statistics-cache/#{hash}"
    end

    def info
      self.class.info
    end

    def to_html
      return @html if @html.present?
      @html = Ddt::StatisticForm.new(self).to_html
      @html += "<div class='statistic-content'>#{statistic_result.to_html}</div>".html_safe if @pr_type == 'result'
      @html
    end

    def to_wechat_html
      statistic_result.to_wechat_html
    end

    def to_hash
      h = {
        from: (@start_time.strftime("%F %T") rescue ''),
        to:   (@end_time.strftime("%F %T") rescue ''),
        title: title,
        zip: false,
        fixed_column: 0
      }
      h.merge! statistic_result.to_hash
      h
    end

    def to_csv(file = StringIO.new)
      statistic_result.to_csv(file)
    end

    def to_xls(file = StringIO.new)
      statistic_result.to_xls(file)
    end

    def statistic_result
      Ddt::StatisticResult.new(self)
    end

    def result
      []
    end

    def title
      ['A', 'B']
    end

    def body
      [
        [1,2],
        [3,4],
      ]
    end

    def foot
      [[]]
    end

    def filters
      []
    end

    # common default time params
    class << self
      def today
        {start_time: now.beginning_of_day, end_time: now.end_of_day}
      end

      def this_day
        {date: now.strftime("%F")}
      end

      def this_month
        {year: now.year, month: now.month}
      end

      def this_week
        {week: 0}
      end
    end
    [:today, :this_day, :this_month, :this_week].each do |name|
      define_method name do
        self.class.send name
      end
    end

    # common filter
    def branches_collection
      accessible_branches.map{|branch| {id: branch.id, name: branch.name}}
    end

    def one_branch?
      branch_id.present? && branch_id.to_i != ALL_BRANCH
    end

    def all_branch?
      branch_id.present? && branch_id.to_i == ALL_BRANCH
    end

    def abstract_branch?
      branch_id.present? && branch_id.to_i == ABSTRACT_BRANCH
    end

    def find_one_branch
      if branch_id.present?
        if branch_id == ABSTRACT_BRANCH
          shop.abstract_branch
        else
          shop.branches.find(branch_id)
        end
      end
    end

    def filter_branch(support_all: true, support_abstract: false)
      local_datas = []
      local_datas << {id: ALL_BRANCH, name: '所有门店'} if support_all
      local_datas << {id: ABSTRACT_BRANCH, name: '平台'} if support_abstract
      local_datas += branches_collection
      {name: 'branch_id', type: 'ddselect2', data: {useas: "local_select", "local-datas" => local_datas, single: true, placeholder: "选择门店"}}
    end

    def filter_year
      {name: 'year', type: 'collection', collection: year_collection, prompt: '选择年份', include_blank: false}
    end

    def filter_month
      {name: 'month', type: 'collection', collection: month_collection, prompt: '选择月份', include_blank: false}
    end

    def filter_week
      {name: 'week', type: 'collection', collection: week_collection, include_blank: false}
    end

    def filter_date
      {name: 'date', type: 'date', placeholder: '选择日期'}
    end

    def filter_start_time
      { name: 'start_time', type: 'datetime', placeholder: '开始时间'}
    end

    def filter_end_time
      { name: 'end_time', type: 'datetime', placeholder: '结束时间'}
    end

    def filter_time_interval(support_all: true)
      time_intervals = @shop.time_intervals.map(&:select_json)
      local_datas = support_all ? [{id: ALL_TIME_INTERVAL, name: '所有时段'}] +  time_intervals : time_intervals
      { name: 'time_interval_id', type: 'ddselect2', data: { useas: 'local_select', 'local-datas' => local_datas, single: true, placeholder: '选择时段'}}
    end

    # title
    # body
    # is_custom_tr

    def custom_thead?
      false
    end

    def custom_thead
      # [
      #   [{name: xx, th_attrs: {}}]
      # ]
      []
    end

    def link_template
      # column_index => template
      # eg:
      # {
      #   1 => "<a href='%s' >%s</a>",
      # }
      {}
    end

    def link_hash
      # {name => id}
      {}
    end

    def order_link_template
      "<a href='/backend/shops/#{shop.id}/orders/%s' target='_blank'>%s</a>"
    end

    def order_number_id_hash(items)
      values = {}
      items.each do |item|
        values[item[:order_number] ] = item[:order_id]
      end
      values
    end

    def wrap_paginate(collection)
      current_page = (page||1).to_i
      total_size = (collection.size == 20 ? 20*current_page+1 : 20+20*(current_page-1))
      collection = WillPaginate::Collection.create(current_page, 20, total_size) do |pager|
        pager.replace collection
      end
    end

    def time_interval_clause
      Ddt::StatisticBase::build_time_interval_clause(@time_interval)
    end

    def self.build_time_interval_clause(time_interval)
      if time_interval.present?
        start = time_interval.start.strftime('%T')
        last = time_interval.end.strftime('%T')
        if start <= last
          "(CAST(paid_at AS TIME) >= '#{start}' and CAST(paid_at AS TIME) < '#{last}')"
        else
          "(CAST(paid_at AS TIME) >= '#{start}' or CAST(paid_at AS TIME) < '#{last}')"
        end
      else
        1
      end
    end

  end
end
