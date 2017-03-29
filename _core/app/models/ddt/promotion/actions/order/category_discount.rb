module Ddt
  class Promotion
    module Actions
      module Order
        class CategoryDiscount < ::Ddt::PromotionAction
          include Ddt::PromotionActionModelName
          has_and_belongs_to_many :categories, class_name: '::Ddt::Category', join_table: 'ddt_categories_promotion_actions', foreign_key: 'promotion_action_id'
          ids_string_for :categories
          preference :discount, :decimal, default: 100
          validates :preferred_discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100}


          def perform(promotable)
            promotable.adjust(reason: :promotion, source: self)
          end

          concerning :AdjustSource do
            def compute_amount_of_adjustment(order)
              items = order.line_items.active.select do |item|
                (item.is_variant? && variant_ids.include?(item.itemable_id)) ||
                (item.is_variant_package? && variant_ids.include?(item.itemable.variant_id))
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

          def all_category_ids
            self.categories.with_sub_ids
          end

          def product_ids
            @product_ids ||= Category.get_product_ids(all_category_ids)
          end

          def variant_ids
            @variant_ids ||= Variant.where(product_id: product_ids).pluck(:id)
          end

        end
      end
    end
  end
end