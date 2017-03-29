module Ddt
  class DiscountPlanItem < Ddt::Base
    include BelongsToBranch
    belongs_to :discount_plan
    has_and_belongs_to_many :categories, join_table: "ddt_discount_plan_items_categories"
    has_and_belongs_to_many :variants, join_table: "ddt_discount_plan_items_variants"
    has_and_belongs_to_many :combos, join_table: "ddt_discount_plan_items_combos"
    ids_string_for :categories, :variants, :combos
    set_from :discount_plan
    acts_as_type :item_type, [:category, :variant, :combo, :all], %W[分类折扣 单品折扣 套餐折扣 整单折扣]
    validates_presence_of :item_type, :discount
    validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1}
    def desc
      case item_type.to_sym
      when :category
        "#{item_type_name} [#{categories.map(&:name).join(",")}] 折扣#{discount}"
      when :variant
        "#{item_type_name} [#{variants.map(&:name_with_options_text).join(",")}] 折扣#{discount}"
      when :combo
        "#{item_type_name} [#{combos.map(&:name).join(",")}] 折扣#{discount}"
      when :all
        "#{item_type_name} #{discount}"
      end
    end

    def satisfy?(line_item)
      case item_type.to_sym
      when :category
        (line_item.is_variant? && (line_item.itemable.category_ids & self.categories.map(&:id)).present? ) ||
        (line_item.is_variant_package? && (line_item.itemable.variant.category_ids & self.categories.map(&:id)).present? )
      when :variant
        (line_item.is_variant? && self.variant_ids.include?(line_item.itemable_id)) ||
        (line_item.is_variant_package? && self.variant_ids.include?(line_item.itemable.variant_id))
      when :combo
        line_item.is_combo_package? && self.combo_ids.include?(line_item.itemable.combo_id)
      when :all
        true
      end
    end
  end
end