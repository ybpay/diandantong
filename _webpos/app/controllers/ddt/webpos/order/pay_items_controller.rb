module Ddt
  module Webpos
    module Order
      class PayItemsController < Webpos::BaseController
        include Ddt::Webpos::OrderBill
        before_action :set_order
        before_action :set_pay_item
        check_permission :branch, :order, :settle

        def paid
          if @pay_item.blank?
            render json: { errors: '支付项目已经被他人删除，请刷新此订单'}, status: :bad_request
          elsif @pay_item.pay_platform?
            render json: { errors: '使用支付平台的支付项目不能手动确认'}, status: :bad_request
          else
            begin
              @order.change_pay_item_to_paid(@pay_item, paid_amount: params[:paid_amount], change: params[:change])
              @bill = order_bill(@order, is_paid_bill: true) if @order.is_paid? && params[:is_local_printed]
              render :show
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

        # 收银员扫码
        def pay_by_seller_scan
          payment = @pay_item.payment

          if payment.pending?
            if payment.respond_to? :query
              unless payment.query
                unless payment.closed?
                  render json: { errors: '请等待用户操作完成, 若需要重新扫码, 请等待用户取消后重新结算'}, status: :bad_request
                  return
                end
              end
            end
          end

          if payment.closed?
            @pay_item.refresh
            payment = @pay_item.payment
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
          if @pay_item.is_unpaid? and @pay_item.pay_platform?
            @pay_item.payment.try(:query)
            @order.reload
            set_pay_item
          end
          @bill = order_bill(@order, is_paid_bill: true) if @order.is_paid? && params[:is_local_printed]
        end

        def close
          @pay_item.close
          @order.save
          @order.reload
          set_pay_item
          render :show
        end

        def refund
          if @pay_item.can_refund?
            success = @pay_item.refund
            if success
              @order.reload
              set_pay_item
              render :show
            else
              render json: {errors: '退款失败'}, status: :bad_request
            end
          else
            render json: { errors: '不能退款'}, status: :bad_request
          end
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
          @pay_item = @order.pay_items.find(params[:id])
        end
      end
    end
  end
end
