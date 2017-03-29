module Ddt
  module Weixin
    module User
      module Coupon
        class VouchersController < WeixinApplicationController
          respond_to :json
          before_action :set_collection, only: [:index]
          before_action :set_voucher, only: [:show, :apply_refund, :cancel_apply_refund]
          def index
            @vouchers = @collection.paginate(page: params[:page], per_page: params[:per_page] || 8)
          end

          def show
          end

          def apply_refund
            @voucher.apply_refund
            render :show
          end

          def cancel_apply_refund
            @voucher.cancel_apply_refund
            render :show
          end

          private

          def set_collection
            if params[:state]
              case params[:state].to_sym
              when :available then @collection = @current_user.vouchers.available
              when :applied   then @collection = @current_user.vouchers.applied
              when :expired   then @collection = @current_user.vouchers.expired
              when :refund    then @collection = @current_user.vouchers.refund
              end
            else
              @collection = @current_user.vouchers
            end
          end

          def set_voucher
            @voucher = @current_user.vouchers.find(params[:id])
          end
        end
      end
    end
  end
end
