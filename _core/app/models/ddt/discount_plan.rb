module Ddt
  class DiscountPlan < Ddt::Base
    include Ddt::SoftDeletable
    include BelongsToBranch
    has_many :discount_plan_items, inverse_of: :discount_plan
    alias_method :items, :discount_plan_items
    validates_presence_of :name
    accepts_nested_attributes_for :discount_plan_items, allow_destroy: true

    # scope
    scope :active, -> {
      weekday_key =
        case Time.now.wday
        when 0; :enable_on_sunday;
        when 1; :enable_on_monday;
        when 2; :enable_on_tuesday;
        when 3; :enable_on_wednesday;
        when 4; :enable_on_thursday;
        when 5; :enable_on_friday;
        when 6; :enable_on_saturday;
        end
      where('start_at IS NULL OR start_at < ?', Time.now)
        .where('end_at IS NULL OR end_at > ?', Time.now)
        .where(weekday_key => true)
    }

    def desc
      items.map(&:desc)
    end

    def calculate(order)
      order.line_items.active.include_itemables(variant: { product: :categories }, variant_package: {variant: :product}, combo_package: [:combo])
      discount_amount = items.map do |item|
        order.line_items.active.select(&:can_discount?).select{|line_item| item.satisfy?(line_item)}.map(&:subtotal).sum * (1 - item.discount)
      end.sum.round(2)
    end

    concerning :AdjustSource do
      included do
        def compute_amount_of_adjustment(order)
          -calculate(order)
        end

        def get_label_of_adjustment(order)
          name
        end

        def get_item_adjustments(order)
          items.map{|item|
            order.line_items.active.select(&:can_discount?).select{|line_item| item.satisfy?(line_item)}.map{|line_item|
              amount = -line_item.subtotal * (1 - item.discount)
              line_item.get_item_adjustment(amount)
            }
          }.flatten
        end
      end
    end
  end
end