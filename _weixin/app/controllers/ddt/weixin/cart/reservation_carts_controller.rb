module Ddt
  class Weixin::Cart::ReservationCartsController < WeixinApplicationController
    include Weixin::BaseCartController
    def update_reservation_info
      @cart.update_reservation_info(reservation_info_params)
      render :show
    end
    private
    def reservation_info_params
      params.require(:cart).permit(:name, :phone, :gender, :reservation_date, :reservation_time_point_id)
    end
  end
end