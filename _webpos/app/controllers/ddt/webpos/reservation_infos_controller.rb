module Ddt
  module Webpos
    class ReservationInfosController < Webpos::BaseController
      respond_to :json

      def search
        @reservation_infos =  @current_shop.reservation_infos.where("phone like ?", "#{params[:phone]}%").limit(5)
        render json: @reservation_infos.map{|info| info.try(:serializable_hash, only: [:name, :phone, :gender]) }.compact
      end
    end
  end
end