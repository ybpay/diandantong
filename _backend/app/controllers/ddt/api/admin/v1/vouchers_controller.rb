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
            @voucher.refund_coupon
            render_empty_success(message: "代金券已退款")
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
