module Ddt
  module Api
    module V1
      module Backend
        class VouchersController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_voucher, only: [:show, :refund]

          def index
            vouchers = @shop.vouchers.ransack(params[:q]).result
            render_paginated(vouchers)
          end

          def show
            render_resource(@voucher)
          end

          def refund
            result = @voucher.refund_coupon
            if result
              render_empty_success(message: "代金券已退款")
            else
              render json: { errors: [{ status: 422, detail: "代金券退款失败" }] }, status: :unprocessable_content
            end
          rescue StandardError => e
            render json: { errors: [{ status: 422, detail: e.message }] }, status: :unprocessable_content
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_voucher
            @voucher = @shop.vouchers.find(params[:id])
          end
        end
      end
    end
  end
end
