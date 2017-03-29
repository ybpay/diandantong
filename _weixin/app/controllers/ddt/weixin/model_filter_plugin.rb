#encoding: utf-8
module Ddt
  module Weixin::ModelFilterPlugin

    def self.included(mod)
      def filters
        @filters = Rails.cache.fetch([@current_shop, 'branches-filters'], expires_in: 10.minutes) do
          filters = []
          params[:filters].try(:each) do |filter, value|
            if value.empty?
              filters << self.send(filter)
            else
              filters << self.send(filter, value)
            end
          end
          filters
        end
        render :json => @filters
      end
    end

    def query_pname
      @query_pname || 'query'
    end

    def tag_filter(shop = @current_shop)
      # 以前 controller 实现方式，如果依靠 @ransack 则不会有这种问题
      # @local_events = @current_block.topics.not_top.recent.not_ban
      # .of_audit_mode(@current_block.audit_mode)
      # .by_query_time(params[:query_time], params[:fresh])
      # .paginate(page: params[:page], per_page: (params[:per_page] || 10))
      ModelFilter.new(
          op: "#{query_pname}[branch_tag_id_eq]",
          label: '标签过滤',
          value: nil,
          allow_default: true
      ) do |f|
        filters = []
        shop.branch_tags.each { |t|
          if t.count > 0
            filters << ModelFilter.new({op: "#{query_pname}[branch_tag_id_eq]", label: t.name, value: t.id})
          end
        }
        filters
      end
    end

    def zone_filter(
        shop = @current_shop,
        zones = nil,
        parent=nil
    )
      zones = shop.zones.all if zones.nil?
      if parent.nil?
        ModelFilter.new(
            op: "#{query_pname}[in_zone]",
            label: '全城',
            value: nil,
            allow_default: true,
        ) do |f|
          sub = zone_filter(shop, zones, f)
          f.value = ''
          sub
        end
      else
        sub_zones = zones.select { |zone| parent.value == zone.parent_zone_id }
        sub_zones.map do |zone|
          ModelFilter.new(
              op: parent.op,
              label: zone.name,
              value: zone.id,
              allow_default: true,
          ) do |f|
            zone_filter(shop, zones - sub_zones, f) # build hierarchy from remain zones
          end
        end
      end
    end

    def sort_filter(columns = [])
      # q[s]=views_count+desc
      return [] if columns.nil?
      columns = columns.split(/\s+/) if columns.is_a? String
      ModelFilter.new(
          op: "#{query_pname}[s]",
          label: '综合排序',
          value: '',
          allow_default: true
      ) do |f|
        columns.collect do |column|
          [
              ModelFilter.new({
                                  op: f.op,
                                  label: t("activerecord.attributes.ddt/#{controller_name.singularize}.#{column}") + '+',
                                  value: "#{column} asc"
                              }),
              ModelFilter.new({
                                  op: f.op,
                                  label: t("activerecord.attributes.ddt/#{controller_name.singularize}.#{column}") + '-',
                                  value: "#{column} desc"
                              })
          ]
        end.flatten()
      end


    end

  end
end

