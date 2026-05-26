module Ddt
  class PromotionAction < Ddt::Base

    include Ddt::SoftDeletable
    include Ddt::BelongsToShop
    belongs_to :promotion, class_name: 'Ddt::Promotion', inverse_of: :promotion_actions

    scope :of_type, ->(t) { where(type: t) }
    scope :in_shop, -> { where(branch_id: nil)}
    set_from :promotion

    def perform(promotionable)
      raise "perform should be implemented in (#{self.class.name}), sub-class of PromotionAction"
    end
  end
end
