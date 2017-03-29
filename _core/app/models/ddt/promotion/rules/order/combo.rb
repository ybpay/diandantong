# encoding:utf-8
module Ddt
  class Promotion
    module Rules
      module Order
        class Combo < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          has_and_belongs_to_many :combos, class_name: '::Ddt::Combo', join_table: 'ddt_combos_promotion_rules', foreign_key: 'promotion_rule_id'
          ids_string_for :combos

          preference :match_policy, :string, default: :match_any

          acts_as_type :preferred_match_policy, [:match_all, :match_any, :match_none], %W[全部包含 包含任一 全部不包含]

          def applicable?(promotable)
            promotable.respond_to?(:combos)
          end

          def eligible?(promotable)
            if self.is_match_all?
              combos.all? {|p| promotable.combos.include?(p) }
            elsif self.is_match_any?
              promotable.combos.any? {|p| combos.include?(p) }
            else
              promotable.combos.none? {|p| combos.include?(p) }
            end
          end

        end
      end
    end
  end
end