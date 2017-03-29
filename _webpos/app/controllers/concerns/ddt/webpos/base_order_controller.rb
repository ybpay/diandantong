module Ddt
  module Webpos
    module BaseOrderController
      extend ActiveSupport::Concern
      include Ddt::Webpos::OrderBill
      included do
        respond_to :json
        before_action :set_order_type
        before_action :set_order, except: [:create]
        actions_map = {
          [:show, :bill] => :show,
          confirm: :confirm,
          complete: :complete,
          cancel: :cancel,
          hasten: :hasten,
          [:change_vip_info, :unbind_vip_info] => :change_vip_info,
          [:credits_deduction, :cancel_credits_deduction, :card_deduction, :moling, :cancel_moling, :apply_coupon, :rollback_coupon, :apply_voucher, :rollback_voucher, :create_pay_items, :clear_pay_items, :pay_all_pay_items] => :settle,
          [:privilege_discount ,:privilege_reduction ,:privilege_free] => :privilege_discount,
          [:cancel_privilege_discount ,:cancel_privilege_reduction ,:cancel_privilege_free] => :cancel_privilege_discount,
          add_discount_plan: :add_discount_plan,
          cancel_discount_plan: :cancel_discount_plan,
          add_disabled_promotion: :add_disabled_promotion,
          remove_disabled_promotion: :remove_disabled_promotion
        }
        check_permission :branch, :order, actions_map, only: actions_map.keys.map{|k| Array(k)}.inject(:+)
        before_action :check_can_change_total, only: [:credits_deduction, :cancel_credits_deduction, :card_deduction, :privilege_discount, :privilege_reduction, :privilege_free, :moling, :cancel_privilege_discount, :cancel_privilege_reduction, :cancel_privilege_free, :cancel_moling, :apply_coupon, :rollback_coupon, :apply_voucher, :rollback_voucher, :add_discount_plan, :cancel_discount_plan, :add_disabled_promotion, :remove_disabled_promotion]
      end

      def show
        if params[:check_moling] == "true" && @order.moling_blank?
          @order.moling
          @order.update_total_and_save if @order.moling_present?
        end
        fresh_when(@order)
      end

      def cancel
        @order.cancel(params[:cancel_reason]) if @order.can_cancel?
        if @order.errors.present?
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        else
          render :show
        end
      end

      def confirm
        @order.confirm if @order.can_confirm?
        if @order.errors.present?
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        else
          render :show
        end
      end

      def complete
        @order.complete if @order.can_complete?
        if @order.errors.present?
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        else
          render :show
        end
      end

      def change_vip_info
        @vip_info = @current_shop.vip_infos.find(params[:vip_info_id])
        if @current_branch.moling_auto?
          @order.cancel_moling
          @order.update_total
          @order.change_vip_info(@vip_info)
          @order.moling
          @order.update_total_and_save
        else
          @order.change_vip_info(@vip_info)
        end
        render :show
      end

      def unbind_vip_info
        if @current_branch.moling_auto?
          @order.cancel_moling
          @order.update_total
          @order.unbind_vip_info
          @order.moling
          @order.update_total_and_save
        else
          @order.unbind_vip_info
        end
        render :show
      end

      def credits_deduction
        credits = params[:credits].try(:to_i)
        if @current_branch.moling_auto?
          @order.cancel_moling
          @order.update_total
          if @order.add_credits_deduction(credits)
            @order.update_total
            @order.moling
            @order.update_total_and_save
            render :show
          else
            @order.moling
            @order.update_total_and_save
            render status: :bad_request, json: { errors: @order.errors.full_messages }
          end
        else
          if @order.add_credits_deduction(credits)
            render :show
          else
            render status: :bad_request, json: { errors: @order.errors.full_messages }
          end
        end
      end

      def cancel_credits_deduction
        if @current_branch.moling_auto?
          @order.cancel_moling
          @order.update_total
          @order.cancel_credits_deduction
          @order.update_total
          @order.moling
          @order.update_total_and_save
        else
          @order.cancel_credits_deduction
          @order.update_total_and_save
        end
        render :show
      end

      def card_deduction
        amount = params[:amount].try(:to_i)
        if @order.add_card_deduction(amount)
          render :show
        else
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        end
      end

      def privilege_discount
        discount = params[:discount].try(:to_f)
        disable_discount_amount = params[:disable_discount_amount].try(:to_f)
        if discount.present? && discount > 0 && discount < 1
          if @current_branch.moling_auto?
            @order.cancel_moling
            @order.update_total
            @order.privilege_discount(discount, disable_discount_amount: disable_discount_amount, authorizer: @authorizer)
            @order.update_total
            @order.moling
            @order.update_total_and_save
            @order.add_change_log(:privilege_discount)
            @order.save
          else
            @order.privilege_discount(discount, disable_discount_amount: disable_discount_amount, authorizer: @authorizer)
            @order.update_total_and_save
          end
        end
        render :show
      end

      def privilege_reduction
        reduce_amount = params[:reduce_amount].try(:to_f)
        if reduce_amount.present? && reduce_amount > 0 && reduce_amount <= @order.total
          @order.privilege_reduction(reduce_amount, authorizer: @authorizer)
          @order.update_total_and_save
          @order.add_change_log(:privilege_reduction)
          @order.save
        end
        render :show
      end

      def privilege_free
        @order.privilege_free(authorizer: @authorizer)
        @order.update_total_and_save
        render :show
        @order.add_change_log(:privilege_free)
        @order.save
      end

      def moling
        @order.moling
        @order.update_total_and_save
        render :show
      end

      def cancel_privilege_discount
        if @current_branch.moling_auto?
          @order.cancel_moling
          @order.update_total
          @order.cancel_privilege_discount
          @order.update_total
          @order.moling
          @order.add_change_log(:cancel_privilege_discount)
          @order.update_total_and_save
        else
          @order.cancel_privilege_discount
          @order.update_total_and_save
        end
        render :show
      end

      def cancel_privilege_reduction
        @order.cancel_privilege_reduction
        @order.add_change_log(:cancel_privilege_reduction)
        @order.update_total_and_save
        render :show
      end

      def cancel_privilege_free
        @order.cancel_privilege_free
        @order.add_change_log(:cancel_privilege_free)
        @order.update_total_and_save
        render :show
      end

      def cancel_moling
        @order.cancel_moling
        @order.update_total_and_save
        render :show
      end

      concerning :Coupon do
        def apply_coupon
          @coupon = @current_shop.coupons.find(params[:coupon_id])
          if @coupon.can_apply?(@order, with_error: true)
            @order.apply_coupon(@coupon, authorizer: @authorizer)
            render :show
          else
            render json: { errors: @coupon.errors.full_messages }, status: :bad_request
          end
        end

        def rollback_coupon
          @order.rollback_coupon
          render :show
        end
      end

      concerning :Voucher do
        def apply_voucher
          @voucher = @current_shop.vouchers.find(params[:voucher_id])
          if @voucher.can_apply?(@order)
            @order.apply_coupon(@coupon, authorizer: @authorizer)
            render :show
          else
            render json: { errors: "该订单不能应用该代金券" }, status: :bad_request
          end
        end

        def rollback_voucher
          @order.rollback_coupon
          render :show
        end
      end

      def bill
        append_options = {}
        if params[:options].present?
          append_options = JSON.parse(params[:options]).symbolize_keys
        end
        render json: { bill: order_bill(@order, {is_paid_bill: @order.is_paid?}.merge(append_options)) }
      end

      def create_pay_items
        @order.is_local_printed = params[:is_local_printed]
        pay_itemables = OrderService::PayItemable.init_list(params[:pay_items], shop: @current_shop)
        if @order.create_pay_items(pay_itemables)
          render :show
        else
          render json: { errors: @order.errors.full_messages }, status: :bad_request
        end
      end

      def clear_pay_items
        if @order.pay_items.select{|it| it.pay_platform? and it.created_at > 15.seconds.ago}.present?
          render json: { errors: '请等待客户支付完成或取消后, 再重新结算'}, status: :bad_request
        elsif @order.clear_pay_items
          render :show
        else
          render json: { errors: @order.errors.full_messages }, status: :bad_request
        end
      end

      def pay_all_pay_items
        if @order.pay_all_pay_items
          @bill = order_bill(@order, is_paid_bill: true) if @order.is_paid? && params[:is_local_printed]
          render :show
        else
          render json: { errors: @order.errors.full_messages }, status: :bad_request
        end
      end

      def hasten
        if params[:line_item_id].present?
          @order.hasten(track_from: @track_from, line_item_id: Integer(params[:line_item_id]))
        else
          @order.hasten(track_from: @track_from)
        end

        if @order.errors.blank?
          render json: {}
        else
          render json: { errors: @order.errors.full_messages }, status: :bad_request
        end
      end

      concerning :DiscountPlan do
        def add_discount_plan
          @discount_plan = @current_branch.discount_plans.find(params[:discount_plan_id])
          if @current_branch.moling_auto?
            @order.cancel_moling
            @order.update_total
            @order.add_discount_plan(@discount_plan, authorizer: @authorizer)
            @order.update_total
            @order.moling
            @order.update_total_and_save
          else
            @order.add_discount_plan(@discount_plan, authorizer: @authorizer)
            @order.update_total_and_save
          end
          render :show
        end

        def cancel_discount_plan
          if @current_branch.moling_auto?
            @order.cancel_moling
            @order.update_total
            @order.cancel_discount_plan
            @order.update_total
            @order.moling
            @order.update_total_and_save
          else
            @order.cancel_discount_plan
            @order.update_total_and_save
          end
          render :show
        end
      end

      def add_disabled_promotion
        @promotion = current_shop.order_promotions_including_branch.find(params[:promotion_id]) rescue nil
        @promotion = current_branch.product_promotions.find(params[:promotion_id]) if @promotion.nil?
        @order.add_disabled_promotion(@promotion)
        @order.update_promotion(force: true)
        @order.update_total_and_save
        render :show
      end

      def remove_disabled_promotion
        @promotion = current_shop.order_promotions_including_branch.find(params[:promotion_id]) rescue nil
        @promotion = current_branch.product_promotions.find(params[:promotion_id]) if @promotion.nil?  
        @order.remove_disabled_promotion(@promotion)
        @order.update_promotion(force: true)
        @order.update_total_and_save
        render :show
      end

      private

      def set_order_type
        @order_type = controller_name.gsub('_orders', '')
      end

      def set_order
        if %W[show hasten].include? action_name
          @order = Ddt::OrderService::Orders.includes(:line_items, :order_change_logs, :adjustments, :form_contents, :pay_items).find(params[:id])
        else
          @order = @current_branch.orders.send(@order_type).find(params[:id])
        end
        @order.operator = current_account
        @order.terminal_id = @terminal_id
      end

      def base_cart_params
        {
          branch: @current_branch,
          waiter: current_account,
          track_from: @track_from,
          is_local_printed: params[:is_local_printed],
          terminal_id: @terminal_id
        }
      end

      def check_can_change_total
        unless @order.can_change_total?(need_errors: true)
          render json: { errors: @order.errors.full_messages }, status: :bad_request
        end
      end
    end
  end
end
