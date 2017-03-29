module Ddt
  module CommonApi
    module V1
      module BaseOrderController
        extend ActiveSupport::Concern
        included do
          respond_to :json
          before_action :set_order_type
          # before_action :set_order_collection
          before_action :set_order, except: [:create, :create_and_pay]
          check_permission :branch, :order, {
            [:show] => :show,
            cancel: :cancel,
            confirm: :confirm,
            complete: :complete,
            [:change_vip_info, :unbind_vip_info] => :change_vip_info,
            [ :credits_deduction, :cancel_credits_deduction, :card_deduction, :moling, :cancel_moling] => :settle,
            [:privilege_discount ,:privilege_reduction ,:privilege_free] => :privilege_discount,
            [:cancel_privilege_discount ,:cancel_privilege_reduction ,:cancel_privilege_free] => :cancel_privilege_discount,
            hasten: :hasten,
            add_discount_plan: :add_discount_plan,
            cancel_discount_plan: :cancel_discount_plan,
            add_disabled_promotion: :add_disabled_promotion,
            remove_disabled_promotion: :remove_disabled_promotion
          }, only: [:show, :cancel, :confirm, :complete, :change_vip_info, :unbind_vip_info, :card_deduction, :hasten]
          before_action :check_can_change_total, only: [
            :credits_deduction,
            :cancel_credits_deduction,
            :card_deduction,
            :privilege_discount,
            :privilege_reduction,
            :privilege_free,
            :moling,
            :cancel_privilege_discount,
            :cancel_privilege_reduction,
            :cancel_privilege_free,
            :cancel_moling,
            :apply_coupon,
            :rollback_coupon,
            :apply_voucher,
            :rollback_voucher,
            :add_discount_plan,
            :cancel_discount_plan,
            :add_disabled_promotion,
            :remove_disabled_promotion]
        end

        def show
          if params[:check_moling] == "true" && @order.moling_blank?
            @order.moling
            @order.update_total_and_save if @order.moling_present?
          end
          fresh_when(@order, last_modified: @order.modified_at)
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

        def bill
          append_options = {}
          if params[:options].present?
            append_options = JSON.parse(params[:options]).symbolize_keys
          end
          render json: { bill: order_bill(@order, {is_paid_bill: @order.is_paid?}.merge(append_options)) }
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

      concerning :CreditPromotion do

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
      end

        def card_deduction
          amount = params[:amount].try(:to_i)
          if @order.add_card_deduction(amount)
            render :show
          else
            render status: :bad_request, json: { errors: @order.errors.full_messages }
          end
        end

        def hasten
          if params[:line_item_id].present?
            @order.hasten(track_from: params[:track_from], line_item_id: Integer(params[:line_item_id]))
          else
            @order.hasten(track_from: params[:track_from])
          end

          render json: {}
        end

        def moling
          @order.moling
          @order.update_total_and_save
          render :show
        end

        def cancel_moling
          @order.cancel_moling
          @order.update_total_and_save
          render :show
        end

        concerning :DiscountPlan do
          # params: {:discount_plan_id}
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
        concerning :PrivilegePromotion do
          # params: {:discount, :disable_discount_amount}
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

          # params: {:reduce_amount}
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
        end

        concerning :Coupon do
          # params: {:coupon_id}
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
          # params: {:voucher_id}
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

        private

        def base_cart_params
          {
            branch: @current_branch,
            waiter: current_account,
            track_from: params[:track_from],
            is_local_printed: params[:is_local_printed],
            device_id: @device_id
          }
        end

        def order_bill(order, options={})
          is_paid_bill    = options[:is_paid_bill]    rescue false
          is_product_bill = options[:is_product_bill] rescue false
          is_consume_bill = options[:is_consume_bill] rescue false
          is_reprint_bill = options[:is_reprint_bill] rescue false
          is_last_append_product_bill = options[:is_last_append_product_bill] rescue false
          is_money_display = options[:is_money_display]
          case params[:bill_type].to_s
          when '58'
            order.order_detail_in_bill(
              print_spec: "58",
              is_paid_bill: is_paid_bill,
              is_product_bill: is_product_bill,
              is_consume_bill: is_consume_bill,
              is_reprint_bill: is_reprint_bill,
              is_last_append_product_bill: is_last_append_product_bill,
              is_money_display: is_money_display,
              bill_operator: current_account
            )
          when '80'
            order.order_detail_in_bill(
              print_spec: "80",
              is_paid_bill: is_paid_bill,
              is_product_bill: is_product_bill,
              is_consume_bill: is_consume_bill,
              is_reprint_bill: is_reprint_bill,
              is_last_append_product_bill: is_last_append_product_bill,
              is_money_display: is_money_display,
              bill_operator: current_account
            )
          when 'label'
            order.order_detail_in_bill(use_scene: :label, bill_operator: current_account)
          when 'html'
            order.order_detail_in_html(
              is_product_bill: is_product_bill,
              is_consume_bill: is_consume_bill,
              is_last_append_product_bill: is_last_append_product_bill,
              is_money_display: is_money_display,
              bill_operator: current_account
              # TODO
            )
          else
            order.order_detail_in_html
          end
        end

        def set_order_type
          @order_type = controller_name.gsub('_orders', '')
        end

        # def set_order_collection
        #   @order_collection = @current_branch.orders.send(@order_type)
        # end

        def set_order
          # @order = @order_collection.find(params[:id])
          if %W[show hasten].include? action_name
            @order = Ddt::OrderService::Orders.includes(:line_items, :order_change_logs, :adjustments, :form_contents, :pay_items).find_by(id: params[:id], branch_id: @current_branch.id)
          else
            @order = @current_branch.orders.send(@order_type).find(params[:id])
          end
          @order.operator = current_account
          @order.terminal_id = @terminal_id
        end

        def check_can_change_total
          unless @order.can_change_total?(need_errors: true)
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

      end
    end
  end
end
