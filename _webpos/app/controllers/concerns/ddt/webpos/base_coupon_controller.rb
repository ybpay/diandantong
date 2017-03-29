module Ddt
  module Webpos
    module BaseCouponController
      extend ActiveSupport::Concern

      included do
        before_action :set_base_coupon, only: [:exchange_by_code]
      end

      def find_by_code
        base_coupon = base_coupon_scope.actived.available.includes(:exchange_code).where("ddt_exchange_codes.code = ?", params[:code] || params[:exchange_code]).references("ddt_exchange_codes").first
        if base_coupon.present?
          instance_variable_set("@#{controller_name.singularize}", base_coupon)
          if !base_coupon.respond_to?(:can_use_in_branch?) || base_coupon.can_use_in_branch?(@current_branch)
            render :show
          else
            render json: { errors: "该优惠券不能用于该门店" }, status: :bad_request
          end
        else
          render json: { errors: "未找到优惠券" }, status: :bad_request
        end
      end

      def exchange_by_code
        @base_coupon.update(applied_in_branch_id: params[:branch_id], operator: current_account)
        @base_coupon.exchange
        render nothing: true
      end


      private

        def set_base_coupon
          @base_coupon = base_coupon_class.find params[:base_coupon_id]
        end

        def base_coupon_scope
          case controller_name.to_sym
            when :coupons
              @current_shop.coupons
            when :groupons
              @current_shop.groupons
            when :vouchers
              @current_shop.vouchers
          end
        end

        def base_coupon_class
          case controller_name.to_sym
          when :coupons
            Ddt::Coupon
          when :groupons
            Ddt::Groupon
          when :vouchers
            Ddt::Voucher
          end
        end

        def base_coupon_label
          case controller_name.to_sym
          when :coupons
            "优惠券"
          when :groupons
            "团购券"
          when :vouchers
            "代金券"
          end
        end


    end
  end
end
