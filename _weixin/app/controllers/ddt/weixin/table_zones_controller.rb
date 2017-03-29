module Ddt
  class Weixin::TableZonesController < WeixinApplicationController
    respond_to :json
    def index
      @table_zones = @branch.table_zones
      fresh_when(@table_zones)
    end
  end
end
