module Ddt
  module Weixin
    module BaseOrderController
      extend ActiveSupport::Concern
      included do
        respond_to :json
        before_action :set_order_type
        before_action :set_order_collection
        before_action :check_create_order_interval, only: [:create]
        before_action :set_cart, only: [:create, :association_domains, :pay_online]
        before_action :set_order, only: [:show, :get_pay_online, :cancel, :confirm, :complete, :get_permissions,
                                         :append_itemables, :hasten, :call_waiter,:request_pay, :refresh_location, :ship, :avariable_coupons, :apply_coupon, :clear_coupon, :start_shipment, :finish_shipment, :assign_to_self, :check_order_paid]
        before_action :add_deduction, only: [:create]
      end

      def show
      end

      def get_pay_online
        @payment = @order.current_payment
        if @payment.present?
          result = @payment.process(request, callback_url: "http://#{request.host}:#{request.port}/#{@order.weixin_after_pay_path}")
          render json: result
        else
          render json: { errors: "支付错误" }, status: :bad_request
        end
      end

      def association_domains
        @coupons = @current_user.coupons.available.select { |it|
            it.can_apply?(@cart)
        }
        respond_to do |f|
          f.json { render '/ddt/weixin/order/association_domains'}
        end
      end

      def avariable_coupons
        @coupons = @current_user.coupons.available.select { |it|
            it.can_apply?(@order)
        }
        respond_to do |f|
          f.json { render '/ddt/weixin/order/association_domains'}
        end
      end

      def cancel
        @order.cancel if @order.can_user_cancel?
        if @order.errors.present?
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        else
          render json: {}
        end
      end

      def confirm
        @order.confirm if @order.can_confirm?
        if @order.errors.present?
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        else
          render json: {}
        end
      end

      def complete
        @order.complete if @order.can_complete?
        if @order.errors.present?
          render status: :bad_request, json: { errors: @order.errors.full_messages }
        else
          render json: {}
        end
      end

      def append_itemables
        line_itemables = OrderService::LineItemable.init_list(params[:itemables])
        @order.is_local_printed = false
        @order.append(line_itemables)
        @order
        render json: {}
      end

      def get_permissions
        permissions = []
        if @order && @current_user == @order.user
          permissions += [:cancel, :pay_online, :exchange_code, :hasten, :call_waiter]
          permissions << :append_itemable if @order.can_append_itemable?
        end
        #这块可能需要更严格的权限判断
        if @order && @current_user.is_account_user?
          account = @current_user.account_user
          if account.is_deliveryman? && @order.is_delivery?
            delivery_man_id = @order.shipment.delivery_man_id
            if delivery_man_id == account.id
              permissions += [:index_delivery, :hasten, :start_shipment, :finish_shipment, :complete]
            elsif delivery_man_id.blank?
              permissions += [:index_delivery, :assign_delivery_man]
            end
          else
            permissions += [:cancel, :confirm, :complete]
          end
        end
        render json: { permissions: permissions }
      end

      def hasten
        @order.hasten(track_from: @track_from, line_item_id: params[:line_item_id])
        if @order.errors.blank?
          render json: {}
        else
          render json: {errors: @order.errors.full_messages}, status: :bad_request
        end
      end

      def check_order_paid
        if @order.paid?
          order_url = LinkResource.new({shop: @order.shop}).order_url(@order)
          render json: {
              paid: true,
              order_url: order_url
          }
        else
          render json: {
              paid: false
          }
        end
      end

      private
      def set_order_type
        @order_type = controller_name.gsub('_orders', '')
        @cart_type = @order_type
      end

      def set_order_collection
        if @current_user.is_account_user? || 'eat_in_hall' == @order_type
          @order_collection = @branch.orders.by_type("Ddt::#{@order_type.classify}Order")
        else
          @order_collection = @branch.orders.by_type("Ddt::#{@order_type.classify}Order").by_user(@current_user)
        end
      end

      def set_cart
        @cart_session_key = "#{@branch.id}_#{@cart_type}"
        @cart = OrderService::Cart.const_get(@cart_type.classify).init_from_session(@branch, @current_user, session[@cart_session_key], track_from: @track_from)
      end

      def clear_cart
        session[@cart_session_key] = {}
      end

      def store_cart
        session[@cart_session_key] = @cart.to_session
      end

      def set_order
        @order = @order_collection.where(id: params[:id]).first
        if @order.nil?
          render :json => {errors: ['该订单不存在，或您已经无权限查看！请确认您的微信号仍然有权限查看此订单']}, status: :bad_request
        end
      end

      def add_deduction
        credits = params[:order][:credits_deduction].try(:to_i)
        amount  = params[:order][:card_deduction].try(:to_f)
        @cart.add_card_deduction(amount)
        @cart.add_credits_deduction(credits)
      end

      def check_create_order_interval
        last_create_order_at = @current_user.orders.last.try(:placed_at)
        if last_create_order_at.present? && last_create_order_at > 10.seconds.ago
          render :json => {errors: ['提交过于频繁']}, status: :bad_request
        end
      end



    end
  end
end
