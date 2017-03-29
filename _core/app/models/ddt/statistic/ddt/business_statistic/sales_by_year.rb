#encoding: utf-8
module Ddt
  module BusinessStatistic
    class SalesByYear < ::Ddt::BusinessStatistic::Sales
      include Ddt::BusinessStatistic::Concern::GroupByTime

      attr_accessor :year, :last_year
      hash_attrs({
           年份: :year,
           包含上一年: :include_last_year
      })

      def self.class_info
        {
          name: 'sales_by_year',
          paginate: false,
          permit_params: [:year, :branch_id],
          label: '营业结算(月)',
          sortable: true
        }
      end

      def group_by_column
        :paid_at_year
      end

      def shift_group_by_column
        :created_at_year
      end

      def append_select_column
        'ddt_shifts.branch_id as branch_id'
      end

      def append_group_column
        'branch_id'
      end

      def time_format
        "%02d"
      end

      def initialize(options={})
        super
        @search_by = options[:search_by] || 'shift_opened_at'
        @include_last_year = options[:include_last_year]
        initialize_year_params(options)
        if @include_last_year.nil?
          last_year_options = options.dup
          @last_year = self.class.new(last_year_options.merge!(year: @year-1, include_last_year: false, is_async: false))
        end
      end

      def filter_blk
        Proc.new{|shift_item| shift_item.paid_at.strftime("%m")}
      end

      def labels
        (1..12).map{|i| "#{i}月"}
      end

      def keys
        (1..12).map{|i| "%02d"%i}
      end

      def csv_labels
        labels.map{|l| ["#{l}(本年)", "#{l}(去年)", "#{l}(增长率)"]}.flatten
      end

      def filters
        [
          filter_branch,
          filter_year
        ]
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr1 = [
          {name: '门店', th_attrs: {rowspan:2}},
          {name: '科目代码', th_attrs: {rowspan: 2}},
          {name: '科目名称', th_attrs: {rowspan: 2}},
          {name: '合计', th_attrs: {colspan: 5}}
        ]
        labels.each{|label| tr1 << {name: label, th_attrs: {colspan: 3}}}

        tr2 = [
          {name: "今年#{year}合计"},
          {name: "今年#{year}实收"},
          {name: "今年#{year}折扣"},
          {name: "去年合计"},
          {name: "合计增长率"}
        ]
        labels.each do |label|
          tr2 << {name: "今年"}
          tr2 << {name: "去年"}
          tr2 << {name: "增长率"}
        end

        thead << tr1
        thead << tr2
        thead
      end

      def title
        %W[科目代码 科目名称 合计(本年) 实收(本年) 折扣(本年) 合计(去年) 合计(增长率)] + csv_labels
      end

      def result_include_last_year
        return @result_include_last_year if @result_include_last_year.present?
        @result_include_last_year = {
          this_year: self.year_shift_item_summarys_by_sql,
          last_year: @last_year.year_shift_item_summarys_by_sql
        }
      end

      cache_result

      def body
        content = []
        r = result_include_last_year
        last_year_summarys = r[:last_year]
        this_year_summarys = r[:this_year]
        this_year_summarys.each do |b_id, summarys|
          branch_name = get_branch_name(b_id)
          summarys.each do |pay_method_id, summary|
            last_year_summary = (last_year_summarys[b_id][pay_method_id] rescue nil)
            summary_amount = (summary[:series]['summary'][:amount] rescue 0)
            summary_actual_amount = (summary[:series]['summary'][:actual_amount] rescue 0)
            summary_no_actual_amount = (summary[:series]['summary'][:no_actual_amount] rescue 0)
            last_year_summary_amount = (last_year_summary[:series]['summary'][:amount] rescue 0)
            row = []
            row << branch_name
            row << summary[:pay_method_code]
            row << summary[:pay_method_name]
            row << summary_amount
            row << summary_actual_amount
            row << summary_no_actual_amount
            row << last_year_summary_amount
            row << inc_rate_label(summary_amount, last_year_summary_amount)
            keys.each do |key|
              amount = (summary[:series][key][:amount] rescue 0)
              last_amount = (last_year_summary[:series][key][:amount] rescue 0)
              row << amount
              row << last_amount
              row << inc_rate_label(amount, last_amount)
            end
            content << row
          end
        end
        content
      end

      def to_highchart
        {
          name: info[:name],
          title: '营业额30天均线',
          subtitle: "#{start_time}~#{end_time}",
          xAxis_categories: labels,
          yAxis_title: '',
          valueSuffix: '',
          series: to_series
        }.to_obj
      end

      def to_series
        series = [{name: '本年', data: []}, {name: '上年', data: []}]
        this_year = []
        last_year = []
        r = result_include_last_year
        last_year_summarys = r[:last_year]
        this_year_summarys = r[:this_year]
        this_year_summarys.each do |pay_method_id, summary|
          last_year_summary = (last_year_summarys[pay_method_id] rescue 0)
          this_year_row = []
          last_year_row = []
          keys.each do |key|
            amount = (summary[:series][key][:amount] rescue 0)
            last_amount = (last_year_summary[:series][key][:amount] rescue 0)
            this_year_row << amount
            last_year_row << last_amount
          end
          this_year << this_year_row
          last_year << last_year_row
        end

        series[0][:data] = 0
        series[1][:data] = 0

        if this_year.present?
          first = this_year.shift
          series[0][:data] = first.zip(*this_year).map{|row| (row.sum.to_f / 30).round(2)}
        end

        if last_year.present?
          first = last_year.shift
          series[1][:data] = first.zip(*last_year).map{|row| (row.sum.to_f / 30).round(2)}
        end
        series
      end

      def foot
        default = []
        (title.size - 2).times{ default.push(0)}
        return [default] if body.blank?
        body_data = body.map{|row| row.shift(3); row}
        first = body_data.shift
        zip_data = first.zip(*body_data)
        @foot = []
        zip_data.each_with_index do|row, index|
          if (index+1) == 5 || (index+1 > 5 && (index+1 - 5)%3==0 )
            # 概率那一列
            amount = zip_data[index-2].sum
            last_amount = zip_data[index-1].sum
            @foot << inc_rate_label(amount, last_amount)
          else
            @foot << row.sum
          end
        end
        [@foot.unshift('总计').unshift('').unshift('')]
      end


    end
  end
end
