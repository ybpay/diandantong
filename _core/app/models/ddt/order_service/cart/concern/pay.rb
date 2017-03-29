module Ddt
  module OrderService
    module Cart
      module Concern
        module Pay
          extend ActiveSupport::Concern
          included do
          end

          def create_pay_item
            pay_itemable = get_pay_itemable
            add_pay_item(pay_itemable) if pay_itemable
          end

          def pay_method_blacklist
            []
          end

          private
          def add_pay_item(pay_itemable)
            pay_item = OrderService::PayItem.new(amount: pay_itemable.amount, pay_method: pay_itemable.pay_method, cart: self)
            pay_item.update(state: :paid, paid_at: current_time) if pay_item.amount == 0 && (!self.is_eat_in_hall? || branch.eat_in_hall_setting.auto_pay_when_zero?)
            self.pay_items.push(pay_item)
            pay_item
          end

          def get_pay_itemable
            OrderService::PayItemable.new(pay_method_name_sym: self.pay_method, amount: self.amount_for_pay, shop: self.shop) if self.pay_method.present?
          end
        end
      end
    end
  end
end