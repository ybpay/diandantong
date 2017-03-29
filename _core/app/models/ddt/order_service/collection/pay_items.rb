module Ddt
  module OrderService
    module Collection
      class PayItems < Collection::Base
        def pay_item_total
          self.map(&:amount).sum.round(2)
        end

        def pay_item_state
          if self.count > 0
            if self.all?(&:is_paid?)
              "paid"
            elsif self.all?(&:is_unpaid?)
              "unpaid"
            else
              "partial_paid"
            end
          else
            "none"
          end
        end

        def paid?
          pay_item_state == "paid"
        end
        alias_method :is_paid?, :paid?

        def not_paid?
          !paid?
        end

        scope :tick_for_account, ->{ select(&:tick_for_account?)}
        scope :vip_card_pay, ->{ select(&:vip_card_pay?)}
        scope :pay_platform, ->{ select(&:pay_platform?) }
        scope :not_pay_platform, ->{ reject(&:pay_platform?) }
        scope :paid, ->{ select(&:is_paid?) }
        scope :unpaid, ->{ select(&:is_unpaid?) }
        scope :appended, ->{ select(&:is_append) }

        def paid_amount
          self.select(&:is_paid?).map(&:amount).sum
        end

        def actual_amount
          map(&:actual_amount).sum
        end

        def not_actual_amount
          map(&:not_actual_amount).sum
        end

        def pay_method_name
          if self.count > 0
            self.map(&:pay_method_name).join(" ")
          else
            '无'
          end
        end
        alias_method :pay_method_names, :pay_method_name

        def current_pay_item
          self.first
        end

        def current_pay_method
          current_pay_item.try(:pay_method)
        end

        def with_pay_method
          pay_method_ids = self.map(&:pay_method_id)
          pay_methods = PayMethod.find(pay_method_ids)
          self.map do |pay_item|
            pay_item.pay_method = pay_methods.detect{|pay_method| pay_method.id == pay_item.pay_method_id }
            pay_item
          end
        end
      end
    end
  end
end
