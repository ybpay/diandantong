#encoding: utf-8
module Ddt
  class GrouponVersion < Ddt::AbstractCouponVersion
    include SellableCouponVersion
    include ApplicableCouponVersion
    has_many :groupons, class_name: 'Ddt::Groupon', foreign_key: :abstract_coupon_version_id

    # norminal_value groupon_price

    def branch
      self.shop.abstract_branch
    end

    def branch_id
      self.shop.abstract_branch.id
    end

    def name_with_items
      name
    end

    def value_desc
      name_with_items
    end

    def send_coupon_to_user(user, track_from ,bought_from_order=nil)
      self.groupons.create!({
        base_user: user,
        track_from: track_from,
        bought_from_order_id: bought_from_order.try(:id)
      })
    end
  end
end
