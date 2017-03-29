module Ddt
  class Backend::DeliveryZonesController < Backend::BaseController
    check_permission :branch, :delivery_setting, {index: :show, [:new, :create, :edit, :update, :destroy] => :update}
    include Backend::Included::ActsAsModelController
    before_action :set_delivery_zone, only: [:show, :edit, :update, :destroy]

    def index
       @delivery_zones = @current_branch.delivery_zones
    end

    def new
      @delivery_zone = @current_branch.delivery_zones.build
    end

    def create
      @delivery_zone = @current_branch.delivery_zones.build(delivery_zone_params)
      @delivery_zone.shop = @current_shop
      if @delivery_zone.save
        index
        render :index
      else
        render :new
      end
    end

    def update
      if @delivery_zone.update(delivery_zone_params)
        render 'reset_tr'
      else
        render :edit
      end
    end

    def destroy
      @delivery_zone.destroy
    end

    private
    def set_delivery_zone
      @delivery_zone = @current_branch.delivery_zones.find(params[:id])
    end

    def delivery_zone_params
      # *Ddt::DeliveryZone.attribute_names.reject {|c|c=='id'}.map(&:to_sym)
      params.require(:delivery_zone).permit(
          :shop_id, :branch_id, :cost, :position, :zone_name
      )
    end
  end
end
