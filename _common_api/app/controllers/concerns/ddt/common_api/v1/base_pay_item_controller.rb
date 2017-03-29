#encoding: utf-8
module Ddt
  module CommonApi
    module V1
      module BasePayItemController
        extend ActiveSupport::Concern
        included do

          protected

          def to_pay_item_params
            pay_item_params = {}
            unless params[:pay_number].present?
              raise '请输入支付码'
            else
              # 要利用 pay_number 识别出支付宝还是微信支付还是会员卡支付
              # pay_items: [{:name_sym, :name, :amount}]
              if params[:pay_number].start_with?('13')
                pay_item_params[:name_sym] = 'wechatpay_offline'
                pay_item_params[:name] = '线下微信支付'
              elsif params[:pay_number].start_with?('28')
                pay_item_params[:name_sym] = 'alipay_offline'
                pay_item_params[:name] = '线下支付宝支付'
              elsif params[:pay_number].start_with?('19')
                pay_item_params[:name_sym] = 'vip_card_pay'
                pay_item_params[:name] = '会员卡支付'
              else
                raise '非法支付码'
              end
            end
            pay_item_params
          end

          def internal_pay_online
            @pay_item = @order.pay_items.first
            payment = @pay_item.payment
            case @pay_item.name_sym.try(:to_sym)
              when :alipay_offline
                result = payment.process(
                    request,
                    dynamic_id: params[:pay_number],
                    # dynamic_id_type: params[:dynamic_id_type],
                    request_from: 'seller_scan'
                )
              when :wechatpay_offline
                result = payment.process(
                    request,
                    auth_code: params[:pay_number],
                    trade_type: 'MICROPAY'
                )
              else
                {ok: false}
            end
            if result[:method] == 'exception'
              { ok: false, data: result[:data]}
            elsif result[:data] == 'USERPAYING'
              { ok: true, wait_input_password: true}
            else
              { ok: true }
            end
          end
        end
      end
    end
  end
end
