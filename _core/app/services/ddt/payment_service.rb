# frozen_string_literal: true

module Ddt
  module PaymentService
    class CreatePayment
      def initialize(order:, pay_method:, amount: nil)
        @order = order
        @pay_method = pay_method
        @amount = amount || order.total
      end

      def call
        ApplicationRecord.transaction do
          payment = Ddt::Payment.create!(
            order: @order,
            shop: @order.shop,
            amount: @amount,
            payment_method: @pay_method,
            state: :pending
          )
          PaymentGateway.route(payment)
        end
      end
    end

    class CompletePayment
      def initialize(payment, transaction_id:, paid_at: Time.current)
        @payment = payment
        @transaction_id = transaction_id
        @paid_at = paid_at
      end

      def call
        ApplicationRecord.transaction do
          @payment.update!(
            state: :completed,
            transaction_id: @transaction_id,
            paid_at: @paid_at
          )
          @payment.order.mark_as_paid!
          Ddt::PaymentLog.create!(
            payment: @payment,
            action: :complete,
            message: "Payment completed: #{@transaction_id}"
          )
          @payment
        end
      end
    end

    class Refund
      def initialize(payment, amount: nil, reason: nil)
        @payment = payment
        @amount = amount || payment.amount
        @reason = reason
      end

      def call
        raise ArgumentError, "Payment not completed" unless @payment.completed?

        ApplicationRecord.transaction do
          gateway = PaymentGateway.for(@payment)
          result = gateway.refund(@payment, @amount)

          @payment.update!(state: :refunded) if @amount == @payment.amount
          Ddt::PaymentLog.create!(
            payment: @payment,
            action: :refund,
            message: "Refund: #{@amount} - #{@reason}"
          )
          result
        end
      end
    end

    class PaymentGateway
      SUPPORTED_GATEWAYS = %i[alipay wechatpay wechatpay_v3 baidu cash bank_card member_card].freeze

      def self.route(payment)
        new(payment).route
      end

      def self.for(payment)
        case payment.payment_method_type.to_sym
        when :alipay          then Ddt::PaymentService::AlipayGateway
        when :wechatpay       then Ddt::PaymentService::WechatpayGateway
        when :wechatpay_v3    then Ddt::PaymentService::WechatpayV3Gateway
        when :cash, :bank_card then Ddt::PaymentService::OfflineGateway
        when :member_card     then Ddt::PaymentService::MemberCardGateway
        else raise ArgumentError, "Unsupported payment method: #{payment.payment_method_type}"
        end
      end

      def initialize(payment)
        @payment = payment
      end

      def route
        gateway = self.class.for(@payment)
        gateway.create_payment(@payment)
      end
    end

    class AlipayGateway
      def self.create_payment(payment)
        config = payment.shop.alipay_method
        params = {
          out_trade_no: payment.id.to_s,
          total_amount: payment.amount.to_s,
          subject: "订单 #{payment.order.number}"
        }
        { gateway_url: build_alipay_url(params, config), payment: payment }
      end

      def self.refund(payment, amount)
        { success: true, refund_amount: amount }
      end

      private

      def self.build_alipay_url(params, config)
        "https://openapi.alipay.com/gateway.do?#{URI.encode_www_form(params)}"
      end
    end

    class WechatpayGateway
      def self.create_payment(payment)
        { prepay_id: SecureRandom.hex(16), payment: payment }
      end

      def self.refund(payment, amount)
        { success: true, refund_amount: amount }
      end
    end

    class WechatpayV3Gateway
      def self.create_payment(payment)
        { prepay_id: SecureRandom.hex(16), payment: payment }
      end

      def self.refund(payment, amount)
        { success: true, refund_amount: amount }
      end
    end

    class OfflineGateway
      def self.create_payment(payment)
        Ddt::PaymentService::CompletePayment.call(
          payment,
          transaction_id: "OFFLINE-#{SecureRandom.hex(8)}",
          paid_at: Time.current
        )
      end

      def self.refund(payment, amount)
        { success: true, refund_amount: amount }
      end
    end

    class MemberCardGateway
      def self.create_payment(payment)
        wallet = payment.order.user.vip_info.card_wallet
        raise InsufficientBalanceError, "余额不足" if wallet.balance < payment.amount

        ApplicationRecord.transaction do
          wallet.decrement!(:balance, payment.amount)
          Ddt::PaymentService::CompletePayment.call(
            payment,
            transaction_id: "MC-#{SecureRandom.hex(8)}"
          )
        end
      end

      def self.refund(payment, amount)
        wallet = payment.order.user.vip_info.card_wallet
        wallet.increment!(:balance, amount)
        { success: true, refund_amount: amount }
      end
    end

    class InsufficientBalanceError < StandardError; end
  end
end
