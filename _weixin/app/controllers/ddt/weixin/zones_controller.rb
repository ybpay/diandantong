module Ddt
  class Weixin::ZonesController < WeixinApplicationController

    def index
      @zones = @current_shop.zones
      if params[:hierarchy].present?
        parents = {}
        children = @zones
        count = 0
        until count == children.count
          count = children.count
          children = children.to_a.delete_if { |zone|
            if zone.parent_zone_id.nil? or parents[zone.parent_zone_id].present?
              parents[zone.id] = {
                  id: zone.id,
                  name: zone.name,
                  parent_zone_id: zone.parent_zone_id,
                  sub_zones: []
              }
              if zone.parent_zone_id.present?
                parents[zone.parent_zone_id][:sub_zones] << parents[zone.id]
              end
              true
            else
              false
            end
          }
        end
        @hierarchy = parents.select {|zone_id,zone| zone[:parent_zone_id].nil?}.map{|k,v|v}
        render :json => @hierarchy
      end
    end

    def get_zone_by_city
      @zone = @current_shop.zones.where(name: params[:city]).first
      render :json => @zone
    end
  end
end
