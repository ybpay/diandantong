module Ddt
  class GrouponLineItem < Ddt::Base

    # belongs_to :groupon_version, class_name: 'Ddt::GrouponVersion', inverse_of: :groupon_line_items
    belongs_to :variant,  ->{with_deleted}, class_name: 'Ddt::Variant'
    validates :variant, :price, :groupon_price, :quantity, :unit_name, presence: true
    delegate :shop, to: :groupon_version, allow_nil: true

    before_validation :set_from_variant

    def name_with_quantity
      "#{self.name}*#{self.quantity}"
    end

    private
    def set_from_variant
      if self.price.blank? && self.variant.present?
        self.price     = self.variant.price
        self.unit_name = self.variant.unit_name
        self.name      = self.variant.name_with_options_text
      end
    end
  end
end
