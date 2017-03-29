module Ddt
  class Weixin::Cart::DeliveryCartsController < WeixinApplicationController
    include Weixin::BaseCartController
    include Weixin::BaseCartCouponController
    def update_shipment
      @cart.update_shipment(shipment_params)
      render :show
    end

    private
    def shipment_params
      params.require(:shipment).permit(:delivery_zone_id, :address_id, :delivery_time_id)
    end
  end
end