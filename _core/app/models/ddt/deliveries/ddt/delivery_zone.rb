module Ddt
  class DeliveryZone < Ddt::Base

    include Ddt::ListScope
    include Ddt::BelongsToBranchWithTouch
    validates_presence_of :zone_name, :cost
    after_save :update_branch_min_delivery_fee

    acts_as_list scope: :branch
    default_scope ->{ list_order }

    def name
      zone_name
    end

    def update_branch_min_delivery_fee
      self.branch.delivery_setting.update_column(:min_delivery_fee, self.branch.delivery_zones(:reload).map(&:cost).min) if branch.present?
    end

  end
end
