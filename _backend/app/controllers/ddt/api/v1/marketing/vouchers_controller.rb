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
            @voucher.refund_coupon
            render_empty_success(message: "代金券已退款")
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
