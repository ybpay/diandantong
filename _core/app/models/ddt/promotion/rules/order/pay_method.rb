# encoding:utf-8
# A rule to limit a promotion based on variants in the order.
module Ddt
  class Promotion
    module Rules
      module Order
        class PayMethod < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          has_and_belongs_to_many :pay_methods, class_name: '::Ddt::PayMethod', join_table: 'ddt_pay_methods_promotion_rules', foreign_key: 'promotion_rule_id'
          ids_string_for :pay_methods

          def applicable?(promotable)
            promotable.respond_to?(:in_pay_methods?)
          end

          def eligible?(promotable)
            pay_methods.present? && promotable.in_pay_methods?(pay_methods)
          end
        end
      end
    end
  end
end