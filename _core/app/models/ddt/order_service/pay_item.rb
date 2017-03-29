module Ddt
  module OrderService
    class PayItem
      include OrderService::Concern::Base
      include OrderService::Concern::BelongsToOrder
      belongs_to :pay_method, with_deleted: true
      belongs_to :tick_account, with_deleted: true
      belongs_to :payment
      attr_accessor_with_dirty :id, :state, :amount, :change, :paid_amount, :not_actual_amount, :note,
                    :created_at, :updated_at, :paid_at, :deleted_at, :delete_by_admin, :is_append, :sync_at, :tick_account_id, :tick_account_name

      acts_as_type :state, [:unpaid, :paid, :closed, :refunded], %W[未支付 已支付 己关闭 已退款]
      delegate :get_payment_method,
               :not_pay_platform?, :pay_platform?, :online?, :vip_card_pay?, :tick_for_account?,
               :pay_on_face?, :pay_on_receive?, :pay_on_arrive?, :alipay?, :wechatpay?, :baidupay?, :vip_card_pay?, :bank_card_pay?, :alipay_offline?, :wechatpay_offline?,
               to: :pay_method
      attr_accessor_with_dirty :pay_method_name, :pay_method_name_sym, :pay_method_code, :pay_method_percent_of_actual, :pay_method_builtin, :is_append
      alias_method :name, :pay_method_name
      alias_method :name_sym, :pay_method_name_sym
      boolean_method_for :is_append

      def initialize(params={})
        self.state = :unpaid
        super
        changes_applied if exists?
        cache_info if new?
        set_timestamps if new?
        init_payment if order.exists? && new?
        self.not_actual_amount = get_not_actual_amount
      end

      def init_payment
        if order.exists? && pay_platform? && !is_append? && amount > 0 && payment.blank?
          payment_method = get_payment_method
          if payment_method.present?
            payment = Payment.create({
                order: order,
                payment_method: payment_method,
                amount: amount
              })
            self.payment = payment
          end
        end
      end

      def update_amount(amount)
        update(amount: amount)
        update(not_actual_amount: get_not_actual_amount)
        if pay_platform? && !new_record? && amount_changed?
          payment.update(workflow_state: :checkout, amount: amount) if payment.present?
        end
        # change_to_paid if amount == 0 && is_unpaid?
      end

      def change_to_paid(paid_amount: nil, change: nil)
        if order.active?
          vip_card_pay_action if vip_card_pay?
          tick_for_account_action if tick_for_account?
          update(state: :paid, paid_at: current_time, paid_amount: paid_amount, change: change, not_actual_amount: get_not_actual_amount)
        end
      end

      def destroy
        vip_card_pay_rollback
        super
      end

      concerning :Online do
        def close
          if payment.present?
            result = payment.close
            if result[:success]
              update(state: :closed)
            else
              result
            end
          else
            update(state: :closed)
            {
                success: true,
                message: '已关闭'
            }
          end
        end

        def refresh(force = false)
          # 关闭之前的二维码
          payment = self.payment
          if !payment.present?
            init_payment
            {
                success: true,
                message: 'ok'
            }
          elsif !payment.completed?
            result = payment.close
            if force or result[:success] or payment.closed?
              self.payment = nil
              init_payment;
              {
                  success: true,
                  message: 'ok'
              }
            else
              result
            end
          else
            {
                success: false,
                message: '交易已经完成'
            }
          end
        end

        def can_refund?
          self.state == 'paid' and self.pay_platform? and self.payment.can_refund?
        end

        def refund(options = {})
          if can_refund?
            result = payment.refund!(options)
            if result && result[:success]
              self
            else
              false
            end
          else
            false
          end
        end

        def change_to_refunded
          update(state: :refunded)
        end
      end

      def show_paid_amount?
        return self.pay_on_face? && self.paid_amount.present? && self.paid_amount > 0
      end

      def amount_label
        if show_paid_amount?
          "#{self.amount.round(2)} (实收#{self.paid_amount.round(2)} 找零#{self.change.round(2)})"
        else
          self.amount_in_currency
        end
      end

      def vip_card_pay_action
        order.current_vip.card_wallet.pay(order, amount) if vip_card_pay? && is_unpaid? && amount > 0
      end

      def vip_card_pay_rollback
        if exists? && vip_card_pay? && is_paid? && amount > 0
          log = order.current_vip.card_wallet.wallet_logs.where(reason: :for_vip_card_pay, amount: -amount, order_id: order.id).first
          order.current_vip.card_wallet.rollback(order, -log.amount, -log.cash_amount, -log.extra_amount)
        end
      end

      def tick_for_account_action
        TickAccountItem.create(
          shop_id: self.shop_id,
          branch_id: self.branch_id,
          tick_account_id: self.tick_account_id,
          tick_account_name: self.tick_account_name,
          order_id: self.order.id,
          order_number: self.order.number,
          pay_item_id: self.id,
          amount: self.amount
        )
      end

      def cache_info
        if pay_method.present?
          [:name, :name_sym, :code, :percent_of_actual, :builtin].each do |method_name|
            self.send("pay_method_#{method_name}=", pay_method.send(method_name))
          end
        end
        if tick_account.present?
          self.tick_account_name = tick_account.name
        end
      end

      def get_not_actual_amount
        if pay_method_name_sym.present? && pay_method_name_sym.to_sym == :vip_card_pay
          wallet_id = order.branch.card_wallet.id
          Ddt::WalletLog.where(wallet_id: wallet_id, amount: self.amount, reason: :for_vip_card_pay, order_id: self.order_id).first.try(:extra_amount)||0
        else
          self.amount * (100 - pay_method_percent_of_actual) / 100
        end
      end

      def actual_amount
        amount - not_actual_amount
      end
    end
  end
end
