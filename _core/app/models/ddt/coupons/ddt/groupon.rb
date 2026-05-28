module Ddt
  class Groupon < Ddt::BaseCoupon
    include BaseCouponConcern::SellableCoupon
    belongs_to :groupon_version,  ->{with_discarded}, class_name: 'Ddt::GrouponVersion', foreign_key: :abstract_coupon_version_id
    delegate :branches, :branch_names, :value_desc,  to: :groupon_version

    def exchange_detail
      self.groupon_version.name_with_items
    end

    def after_exchange
      self.touch(:applied_at)
      self.groupon_version.increment!(:used_coupons_count)
    end

    def can_exchange?(in_branch)
      !exchanged? && usable? && branches.include?(in_branch)
    end

    def weixin_show_path
      "weixin/shops/#{self.shop_id}/my?_ng_path=/user/groupons"
    end
    url_method_for :weixin_show
  end
end
