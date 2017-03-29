module Ddt
  module Webpos
    class AddressesController < Webpos::BaseController
      respond_to :json

      def search
        @phone_users =  @current_shop.phone_users.where("phone like ?", "#{params[:phone]}%").limit(5)
        render json: @phone_users.map{|u| u.addresses.first.try(:serializable_hash, only: [:name, :phone, :building, :room_no,:latitude, :longitude]) }.compact
      end
    end
  end
end
