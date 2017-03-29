module Ddt
  class VoucherVersion < Ddt::AbstractCouponVersion
    include SellableCouponVersion
    include ApplicableCouponVersion
    has_many :vouchers, class_name: 'Ddt::Voucher', foreign_key: :abstract_coupon_version_id

    def branch
      self.shop.abstract_branch
    end

    def branch_id
      self.shop.abstract_branch.id
    end

    def send_coupon_to_user(user, track_from, bought_from_order=nil)
      self.vouchers.create!({
        base_user: user,
        track_from: track_from,
        bought_from_order: bought_from_order
      })
    end

    def name_with_items
      name
    end

    def value_desc
      name
    end

  end
end
