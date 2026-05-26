module Ddt
  class PromotionRule < Ddt::Base
    include Ddt::BelongsToShop

    belongs_to :promotion, class_name: 'Ddt::Promotion', inverse_of: :promotion_rules
    scope :in_shop, -> { where(branch_id: nil)}
    scope :of_type, ->(t) { where(type: t) }

    validate :type, presence: true
    validate :unique_per_promotion, on: :create

    set_from :promotion

    def applicable?(promotable)
      raise "applicable? should be implemented in (#{self.class.name}), sub-class of PromotionRule"
    end

    def eligible?(promotable)
      raise "eligible? should be implemented in (#{self.class.name}), sub-class of PromotionRule"
    end

    private
    def unique_per_promotion
      if Ddt::PromotionRule.exists?(promotion_id: promotion_id, type: self.class.name)
        errors[:base] << "Promotion already contains this rule type"
      end
    end
  end
end
