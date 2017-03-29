# encoding:utf-8
# A rule to limit a promotion based on variants in the order.
module Ddt
  class Promotion
    module Rules
      module Order
        class Variant < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          has_and_belongs_to_many :variants, class_name: '::Ddt::Variant', join_table: 'ddt_variants_promotion_rules', foreign_key: 'promotion_rule_id'
          ids_string_for :variants

          preference :match_policy, :string, default: :match_any

          acts_as_type :preferred_match_policy, [:match_all, :match_any, :match_none], %W[全部包含 包含任一 全部不包含]

          def applicable?(promotable)
            promotable.respond_to? :variants
          end

          def eligible?(promotable)
            order = promotable
            if self.is_match_all?
              variants.all? {|p| order.variants.include?(p) }
            elsif self.is_match_any?
              order.variants.any? {|p| variants.include?(p) }
            else
              order.variants.none? {|p| variants.include?(p) }
            end
          end
        end
      end
    end
  end
end