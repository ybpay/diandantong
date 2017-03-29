module Ddt
  module OrderService
    module Collection
      class Adjustments < Collection::Base
        def adjustment_total
          active.map(&:amount).sum.round(2)
        end

        scope :active, ->{ select(&:active?)}
        scope :need_best_select, ->{ select(&:need_best_select?)}

        OrderService::Adjustment.reason_values.each do |reason|
          scope reason, ->{ select{|item| item.send("is_#{reason}?")} }
        end

        scope :privilege, ->{ select(&:privilege?)}
        scope :not_promotion, ->{ reject(&:is_promotion?) }
        scope :discount, ->{ select(&:discount?)}
        scope :not_discount, ->{ select(&:not_discount?)}

        def discount_amount
          active.discount.adjustment_total
        end

        def not_discount_amount
          active.not_discount.adjustment_total
        end
      end
    end
  end
end
