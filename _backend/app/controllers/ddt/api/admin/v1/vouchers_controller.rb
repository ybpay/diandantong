module Ddt
  module Api
    module Admin
      module V1
        class VouchersController < BaseController
          before_action :set_voucher, only: [:show, :refund]

          def index
            vouchers = current_shop.vouchers.ransack(params[:q]).result
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

          def set_voucher
            @voucher = current_shop.vouchers.find(params[:id])
          end
        end
      end
    end
  end
end
