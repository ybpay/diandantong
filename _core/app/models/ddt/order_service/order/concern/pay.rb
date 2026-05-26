module Ddt
  module OrderService
    module Order
      module Concern
        module Pay
          extend ActiveSupport::Concern
          included do
          end

          def is_pay_online?
            !self.multi_pay_item? && [:alipay, :wechatpay, :baidupay].include?(self.pay_method.try(:to_sym))
          end

          def is_not_pay_online?
            !is_pay_online?
          end

          def paid?
            is_paid?
          end

          def is_not_paid?
            !is_paid?
          end

          def single_pay_item?
            !multi_pay_item?
          end

          def pay_method_blacklist
            []
          end

          delegate :paid_amount, :current_pay_item, to: :pay_items
          # cache_column :pay_method_names
          def pay_method_name
            self.pay_method_names = self.pay_method_names || self.pay_items.pay_method_names
          end

          def current_payments
            self.payments.of_payable
          end

          def current_payment
            current_payments.first
          end

          def init_platform_pay_item
            self.pay_items.pay_platform.each{|pay_item| pay_item.init_payment }
          end

          def pay_by_default_method
            if single_pay_item? && is_not_paid?
              pay_itemable = OrderService::PayItemable.new(name_sym: self.default_pay_method, amount: self.amount_for_pay, shop: self.shop)
              pay_item = load_pay_item(pay_itemable)
              # TODO 批量修改支付 收银端不打单
              self.is_local_printed = true
              change_pay_item_to_paid(pay_item)
            end
          end

          # 更新单一支付条目支付金额
          def update_pay_item
            if single_pay_item? && is_not_paid?
              pay_item = self.pay_items.first
              pay_item.update_amount(self.amount_for_pay) if pay_item.present?
              update_pay_info
            end
          end

          concerning :SaveActions do
            def change_pay_item_to_paid(pay_item, paid_amount:nil, change:nil)
              if pay_item.is_unpaid?
                transaction do
                  pay_item.change_to_paid(paid_amount: paid_amount, change: change)
                  add_change_log(:order_pay) if pay_items.is_paid?
                  update_pay_info_and_settle_account_and_save
                end
                after_pay if is_paid?
              end
            end

            def change_pay_item_to_refunded(pay_item)
              if pay_item.is_paid?
                transaction do
                  pay_item.change_to_refunded
                  add_change_log(:order_refund)
                  update_pay_info_and_settle_account_and_save
                end
              end
            end

            def payment_paid(payment)
              pay_item = self.pay_items.detect{|pay_item| pay_item.payment_id == payment.id}
              if pay_item.present? && pay_item.is_unpaid?
                self.is_local_printed = false if pay_item.online?
                change_pay_item_to_paid(pay_item)
              end
            end

            def payment_refunded(payment)
              pay_item = self.pay_items.detect{|pay_item| pay_item.payment_id == payment.id}
              if pay_item.present? && pay_item.is_paid?
                self.is_local_printed = false if pay_item.online?
                change_pay_item_to_refunded(pay_item)
              end
            end

            # 创建或变更单支付
            def load_pay_item(pay_itemable)
              self.errors[:base] << "已经是组合支付" if multi_pay_item?
              self.errors[:base] << "订单已经支付" if is_paid?
              self.errors[:base] << "不支持该支付方式" if pay_method_blacklist.include?(pay_itemable.pay_method_name_sym.try(:to_sym))
              return false if self.errors.present?
              pay_item = self.pay_items.first
              if pay_item.present?
                if pay_item.pay_method == pay_itemable.pay_method
                  # 不变
                  pay_item
                else
                  # 改变
                  pay_item.destroy
                  pay_item = add_pay_item(pay_itemable)
                end
              else
                # 新建
                pay_item = add_pay_item(pay_itemable)
              end
              update_pay_info_and_settle_account_and_save
              pay_item
            end

            # 创建组合支付
            def create_pay_items(pay_itemables)
              unless can_clear_pay_items?
                self.errors[:base] << (self.paid? ? "订单已经完成支付" : "已经支付的在线支付项目不能撤销")
              end
              self.errors[:base] << "不支持该支付方式" if pay_itemables.any?{|pay_itemable| pay_method_blacklist.include?(pay_itemable.pay_method_name_sym.try(:to_sym))}
              self.errors[:base] << "支付总价小于订单总价" if pay_itemables.map(&:amount).sum.to_f.round(2) < get_amount_for_pay.to_f.round(2)
              self.errors[:base] << "支付总价大于订单总价" if pay_itemables.map(&:amount).sum.to_f.round(2) > get_amount_for_pay.to_f.round(2)
              return false if self.errors.present?
              pay_items.destroy_all
              pay_itemables.each{ |pay_itemable| add_pay_item(pay_itemable) }
              update_pay_info_and_settle_account_and_save
              true
            end

            # 清空支付条目
            def clear_pay_items(force: false)
              # 一般情况下，已经支付的订单不支持清空, 反结帐除外
              if !force && paid?
                self.errors[:base] << "支付已经完成，操作失败"
                return false
              end
              if can_clear_pay_items?
                transaction do
                  pay_items.destroy_all
                  update_pay_info_and_settle_account_and_save
                  true
                end
              else
                self.errors[:base] << "已经支付的在线支付项目不能撤销"
                false
              end
            end

            # 支付所有不是在线支付的支付方式
            def pay_all_pay_items
              transaction do
                self.pay_items.not_pay_platform.unpaid.each do |pay_item|
                  pay_item.change_to_paid
                end
                add_change_log(:order_pay) if pay_items.is_paid?
                update_pay_info_and_settle_account_and_save
              end
              after_pay if is_paid?
              true
            end

            def do_anti_settlement
              result = false
              transaction do
                self.anti_settlement = true
                self.add_change_log(:anti_settlement)
                result = self.clear_pay_items(force: true)
                self.anti_settlement = result
              end
              after_anti_settlement if result
              result
            end

            def after_anti_settlement
            end

            def can_append_pay_item?
              is_completed? && is_paid?
            end



            def append_pay_item(pay_itemable, description="")
              if can_append_pay_item? && pay_itemable.amount != 0
                transaction do
                  pay_method = pay_itemable.pay_method
                  amount = pay_itemable.amount
                  note = get_note(description)
                  new_pay_item = OrderService::PayItem.new(
                    pay_method: pay_method,
                    amount: amount,
                    is_append: true,
                    state: :paid,
                    paid_at: self.paid_at,
                    order: self,
                    note: note
                  )
                  self.pay_items.push(new_pay_item)
                  self.add_change_log(:append_pay_item, description: note)
                  self.multi_pay_item = true
                  self.pay_item_total = self.pay_items.pay_item_total
                  update_adjustments if self.total == self.pay_item_total
                  self.save
                  update_shift_data if self.total == self.pay_item_total
                  self
                end
              end
            end

            def destroy_pay_item(pay_item_id)
              if can_append_pay_item? && pay_item_id.present?
                pay_item = self.pay_items.find(pay_item_id)
                if pay_item.present? && pay_item.is_append?
                  transaction do
                    pay_item.destroy
                    note = get_note
                    self.add_change_log(:destroy_pay_item, description: note)
                    self.multi_pay_item = self.pay_items.count > 1
                    self.pay_item_total = self.pay_items.pay_item_total
                    update_adjustments if self.total == self.pay_item_total
                    self.save
                    update_shift_data if self.total == self.pay_item_total
                    self
                  end
                end
              end
            end

            def clear_appended
              appended_pay_items = self.pay_items.appended
              if appended_pay_items.present?
                transaction do
                  self.pay_items.appended.each do |pay_item|
                    pay_item.destroy
                  end
                  update_adjustments
                  self.add_change_log(:clear_appended, description: get_note)
                  self.multi_pay_item = self.pay_items.count > 1
                  self.pay_item_total = self.pay_items.pay_item_total
                  self.save
                  update_shift_data
                  self
                end
              end
            end



            private

            def update_adjustments
              self.update_line_item_not_actual_amount
              self.update_combo_package_item_adjustments
            end

            def update_shift_data
              shift = self.branch.shifts.where("created_at < :paid_at and closed_at > :paid_at", { paid_at: self.paid_at }).first
              shift.update_amount if shift.present?
            end

            def get_note(append='')
              account = Ddt::Account.current
              if account.present?
                "#{account.name} 于 #{Time.now.strftime('%F %T')}: #{append}"
              else
                Time.now.strftime('%F %T')
              end
            end

            def update_pay_info_and_settle_account_and_save
              update_pay_info
              update_settle_account
              save
            end

            def update_settle_account
              self.settle_account = operator if operator.is_a?(Account)
            end
          end

          def can_clear_pay_items?
            !self.pay_items.any?{|pay_item| pay_item.pay_platform? && pay_item.is_paid?}
          end

          def can_anti_settlement?(account)
            account.present? && is_paid? &&
            (( account.is_admin? or account.is_boss? or account.is_worker? ) || order_pay_operator_is?(account) )
          end

          def order_pay_operator_is?(account)
            log = self.order_change_logs.order_pay.last
            log.present? && log.operator == account
          end

          private
          def add_pay_item(pay_itemable)
            pay_item = OrderService::PayItem.new(amount: pay_itemable.amount, pay_method: pay_itemable.pay_method, order: self, tick_account: pay_itemable.tick_account)
            self.pay_items.push(pay_item)
            pay_item
          end

        end
      end
    end
  end
end
