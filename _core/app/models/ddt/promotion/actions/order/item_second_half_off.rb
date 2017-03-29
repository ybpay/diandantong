module Ddt
  class Promotion
    module Actions
      module Order
        class ItemSecondHalfOff < ::Ddt::PromotionAction
          include Ddt::PromotionActionModelName
          has_and_belongs_to_many :variants, class_name: '::Ddt::Variant', join_table: 'ddt_variants_promotion_actions', foreign_key: 'promotion_action_id'
          ids_string_for :variants

          def perform(promotable)
            promotable.adjust(reason: :promotion, source: self)
          end

          concerning :AdjustSource do
            def compute_amount_of_adjustment(order)
              items = order.line_items.active.select do |item|
                (item.is_variant? && self.variant_ids.include?(item.itemable_id)) ||
                (item.is_variant_package? && self.variant_ids.include?(item.itemable.variant_id))
              end
              amount = items.map{|item| item.price / 2 * (item.active_quantity / 2)}.sum * -1
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
              amount = items.map{|item| item.price / 2 * (item.active_quantity / 2)}.sum * -1
              if items.present?
                [items.first.get_item_adjustment(amount.round(2))]
              else
                []
              end
            end
          end
        end
      end
    end
  end
end
