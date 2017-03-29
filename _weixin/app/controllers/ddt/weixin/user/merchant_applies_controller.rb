# encoding: utf-8
module Ddt
  class Weixin::User::MerchantAppliesController < WeixinApplicationController
    before_action :set_merchant_apply, only: [:show, :cancel]

    def create
      if @current_user.merchant_apply.present?
        render json: {error: "已经申请过了"}, status: :bad_request
      else
        @merchant_apply = @current_user.build_merchant_apply(merchant_apply_params)
        @merchant_apply.shop = @current_shop

        if @merchant_apply.save
          render json: {id: @merchant_apply.id}
        else
          render json: {errors: @merchant_apply.errors.full_messages}, status: :bad_request
        end
      end
    end

    def show
      render json: {} if @merchant_apply.nil?
    end

    def cancel
      @merchant_apply.cancel!
      render json: {id: @merchant_apply.id}
    rescue
      render json: {error: "取消失败"}, status: :bad_request
    end

    private
    def merchant_apply_params
      params.require(:merchant_apply).permit(:phone, :note)
    end

    def set_merchant_apply
      @merchant_apply = @current_user.merchant_apply
    end
  end
end
