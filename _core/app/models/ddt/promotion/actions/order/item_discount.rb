module Ddt
  class Promotion
    module Actions
      module Order
        class ItemDiscount < ::Ddt::PromotionAction
          include Ddt::PromotionActionModelName
          has_and_belongs_to_many :variants, class_name: '::Ddt::Variant', join_table: 'ddt_variants_promotion_actions', foreign_key: 'promotion_action_id'
          ids_string_for :variants

          preference :discount, :decimal, default: 100
          validates :preferred_discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100}


          def perform(promotable)
            promotable.adjust(reason: :promotion, source: self)
          end

          concerning :AdjustSource do
            def compute_amount_of_adjustment(order)
              items = order.line_items.active.select do |item|
                (item.is_variant? && self.variant_ids.include?(item.itemable_id)) ||
                (item.is_variant_package? && self.variant_ids.include?(item.itemable.variant_id))
              end
              amount = items.map(&:total).sum * (preferred_discount - 100) / 100.0
              amount.round(2)
            end

            def get_label_of_adjustment(order)
              promotion.name
            end

            def get_item_adjustments(order)
              items = order.line_items.active.select do |item|
                (item.is_variant? && self.variant_ids.include?(item.itemable_id)) ||
                (item.is_variant_package? && self.variant_ids.include?(item.itemable.variant_id))
              end
              items.map do |item|
                item_discount_amount = (item.subtotal * (preferred_discount - 100) / 100.0).round(2)
                item.get_item_adjustment(item_discount_amount)
              end
            end
          end
        end
      end
    end
  end
end