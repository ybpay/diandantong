module Ddt
  class Weixin::User::AddressesController < WeixinApplicationController
    respond_to :json
    before_action :set_address, only: [:update, :destroy, :set_default, :show]
    def index
      @addresses = @current_user.addresses
    end

    def create
      @address = @current_user.addresses.build(address_params)
      if @address.save
        render :show
      else
        render json: { errors: @address.errors.full_messages }, status: :bad_request
      end
    end

    def show
    end

    def update
      if @address.update(address_params)
        render json: {}
      else
        render json: { errors: @address.errors.full_messages }, status: :bad_request
      end
    end

    def destroy
      @address.destroy
      default_address = @current_user.default_address
      if default_address.present?
        render json: {default_id: default_address.id}
      else
        render json: {}
      end
    end

    def set_default
      @address.set_default
      @addresses = @current_user.addresses
      render 'index'
    end

    private
    def address_params
      params.require(:address).permit(:name, :phone, :building, :room_no, :is_default, :longitude, :latitude, :city_name)
    end

    def set_address
      @address = @current_user.addresses.find(params[:id])
    end
  end
end
