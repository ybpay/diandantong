module Ddt
  module Webpos
    module Coupon
      class VouchersController < Webpos::BaseController
        include Ddt::Webpos::BaseCouponController
        check_permission :shop, :voucher, { [:search, :available] => :show, [:find_by_code, :exchange_by_code, :exchange_by_id] => :exchange}

        before_action :set_user, only: [:available, :exchange_by_id]
        before_action :set_voucher, only: [:exchange_by_id]

        def search
          @voucher = @current_shop.vouchers.available.includes(:exchange_code).where("ddt_exchange_codes.code = ?", params[:code]).references("ddt_exchange_codes").first
          if @voucher.present?
            if @voucher.can_exchange? @current_branch
              render :show
            else
              render json: { errors: "该代金券不能用于该门店" }, status: :bad_request
            end
          else
            render json: { errors: "未找到代金券" }, status: :bad_request
          end
        end

        def available
          @vouchers = @user.vouchers.available.select{|voucher| voucher.branch_id == @current_branch.id}
        end

        def exchange_by_id
          @voucher.exchange
          head :ok
        end

        private

        def set_user
          @user = @current_shop.base_users.find(params[:user_id])
        end

        def set_voucher
          @voucher = @user.vouchers.available.find(params[:voucher_id])
        end

      end
    end
  end
end
