# encoding:utf-8
module Ddt
  class ComboItem < Ddt::Base
    acts_as_paranoid
    replicated_model

    include Ddt::ListScope
    include Ddt::BelongsToBranch
    include Ddt::HasVipPrice
    # relation
    belongs_to :combo, class_name: 'Ddt::Combo', touch: true
    has_many :combo_items_variants, class_name: 'Ddt::ComboItemsVariant', dependent: :destroy
    has_many :variants, through: :combo_items_variants, class_name: 'Ddt::Variant', after_add: :touch_combo, after_remove: :touch_combo
    accepts_nested_attributes_for :combo_items_variants, allow_destroy: true

    acts_as_type :price_strategy, [:fixed_price, :dynamic_price], %W[可选产品使用相同价格 可选产品各自使用不同价格]

    # validations
    validates_presence_of :name
    validates :price, :vip_price, :numericality => {:greater_than_or_equal_to => 0}, presence: true, if: :is_fixed_price?
    validate :vip_price_lteq_price, if: :is_fixed_price?
    validates :select_count, numericality: { greater_than_or_equal_to: 1}, presence: true
    validate :combo_items_variants_blank

    # scopes
    acts_as_list scope: [:combo, :deleted_at]
    default_scope ->{ list_order }
    scope :fixed_price, -> { where(price_strategy: :fixed_price)}

    # callbacks
    set_shop_and_branch_from :combo
    before_save :set_prices
    before_save :unset_combo_items_variant_combi_id
    after_save :set_combo_items_variant_combi_id
    after_save :touch_combo


    def touch_combo(variant=nil)
        self.combo.try(:touch)
    end

    def sorted_variants
      combo_items_variants.order(id: :asc).map{|i| i.variant}.compact
    end

    private

      def combo_items_variants_blank
        civs = self.combo_items_variants
        reject = false
        if civs.size == 0
          reject = true
        else
          if civs.all?{|civ| civ._destroy }
            self.combo_items_variants.reload
            reject = true
          end
        end
        self.errors[:base] << '可选产品必须设置' if reject
        reject
      end

      def set_prices
        self.original_price = price
      end

      def unset_combo_items_variant_combi_id
        if !new_record?
          ActiveRecord::Base.connection.execute("UPDATE ddt_combo_items_variants set combi_id = null where combo_item_id = #{self.id}", )
        end
      end

      def set_combo_items_variant_combi_id
        if !new_record?
          ActiveRecord::Base.connection.execute("UPDATE ddt_combo_items_variants set combi_id = CONCAT(combo_item_id, ':', variant_id) where combo_item_id = #{self.id}")
        end
      end
  end
end
