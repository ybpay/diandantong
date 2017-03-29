module Ddt
  module CommonApi
    module V1
      module Order
        class PayItemsController < V1::BaseController
          include V1::BasePayItemController

          before_action :set_order
          before_action :set_pay_item
          check_permission :branch, :order, :settle
          #
          # params: {
          #   order_id:,
          #   is_local_printed:,
          #   pay_items: [{:name_sym, :name, :amount}]
          # }
          #
          def create
            @order.is_local_printed = params[:is_local_printed]
            pay_itemables = OrderService::PayItemable.init_list(params[:pay_items], shop: @current_shop)
            if @order.create_pay_items(pay_itemables)
              render "/ddt/common_api/v1/order/#{@order.type_str}_orders/show"
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end

          #
          # params: {
          #   order_id:,
          #   pay_number:
          #   vip_card_code
          # }
          #
          def create_and_pay
            begin
              pay_item_params = to_pay_item_params
              pay_item_params[:amount] = @order.total
            rescue => e
              render json: {errors: e}, status: :bad_request
              return
            end

            @order.is_local_printed = params[:is_local_printed]
            pay_itemables = OrderService::PayItemable.init_list([pay_item_params], shop: @current_shop)
            if !@order.create_pay_items(pay_itemables)
              render json: { errors: @order.errors.full_messages }, status: :bad_request
              return
            end
            if params[:pay_number].start_with?('19')
              @pay_item = @order.pay_items.first
              @order.change_pay_item_to_paid(@pay_item)
            else
              internal_pay_online
            end
            render :pay_msg
          end

          #
          # params: {:order_id}
          #
          def clear
            if @order.pay_items.select{|it| it.pay_platform? and it.created_at > 15.seconds.ago}.present?
              render json: { errors: '请等待客户支付完成或取消后, 再重新结算'}, status: :bad_request
          elsif @order.clear_pay_items
              render "/ddt/common_api/v1/order/#{@order.type_str}_orders/show"
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end

          #
          # params: {:order_id}
          #
          def paid_all
            if @order.pay_all_pay_items
              render :pay_msg
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end

          #
          # params: {
          #   order_id:
          #   pay_item_id:
          #   # optional
          #   pay_amount:
          #   change:
          # }
          #
          def paid
            if @pay_item.blank?
              render json: { errors: '支付项目已经被他人删除，请刷新此订单'}, status: :bad_request
            elsif @pay_item.pay_platform?
              render json: { errors: '使用支付平台的支付项目不能手动确认'}, status: :bad_request
            else
              begin
                @order.change_pay_item_to_paid(@pay_item, paid_amount: params[:paid_amount].to_f, change: params[:change].to_f)
                render "/ddt/common_api/v1/order/#{@order.type_str}_orders/show"
              rescue => e
                render json: {errors: e.message}, status: :bad_request
              end
            end
          end

          # 客户扫码
          #
          # 刷新二维码也使用这个接口
          # 如果已经支付，就不能刷新
          #
          # params: {
          #   order_id:,
          #   id: # pay_item_id
          # }
          #
          # result: {
          #     method: alipay/wechatpay
          #     version: 支付接口版本
          #     out_trade_no: 订单标识
          #     partner_id: 门店标识
          #     data_type: url/NATIVE/JSAPI
          #     data: ......
          #     qr_code_url:
          # }
          #
          def get_pay_online
            # 如果之前的二维码被使用，可强制刷新之
            @pay_item.refresh(true) if params[:replace] == 'true'
            @payment = @pay_item.payment
            case @pay_item.name_sym.try(:to_sym)
            when :wechatpay
              result = @payment.process(request, trade_type: 'NATIVE')
            when :alipay
              result = @payment.process(request, generate_qr_code: true, request_from: 'buyer_scan')
            end
            render json: result
          end

          #
          # 收银员扫码
          # params: {
          #   order_id:,
          #   id:, # pay_item_id
          #   dynamic_id:, #消费者手机上二维码对应的id
          # }
          #
          def pay_by_seller_scan
            payment = @pay_item.payment

            if payment.pending?
              if payment.respond_to? :query
                unless payment.query
                  render json: { errors: '请等待用户操作完成, 若需要重新扫码, 请等待用户取消后重新结算'}, status: :bad_request
                  return
                end
              end
            end

            case @pay_item.name_sym.try(:to_sym)
            when :alipay_offline
              result = payment.process(
                request,
                dynamic_id: params[:dynamic_id],
                # dynamic_id_type: params[:dynamic_id_type],
                request_from: 'seller_scan'
              )
            when :wechatpay_offline
              result = payment.process(
                request,
                auth_code: params[:dynamic_id],
                trade_type: 'MICROPAY'
              )
            end
            if result[:method] == 'exception'
              result = { ok: false, data: result[:data]}
            elsif result[:data] == 'USERPAYING'
              result = { ok: true, wait_input_password: true}
            else
              result = { ok: true }
            end
            render json: result
          end

          def show
            if @pay_item.is_unpaid? && [:wechatpay_offline, :wechatpay].include?(@pay_item.name_sym.try(:to_sym))
              @pay_item.payment.try(:query)
              @order.reload
              set_pay_item
            end
            render :pay_msg
          end



          private

            def set_order
              @order = @current_branch.orders.find(params[:order_id])
              if %W[paid show].include? action_name
                @order.is_local_printed = params[:is_local_printed]
              end
              @order.terminal_id = @terminal_id
              @order.operator = current_account
            end

            def set_pay_item
              @pay_item = @order.pay_items.find(params[:id]) if params[:id].present?
            end

        end
      end
    end
  end
end
