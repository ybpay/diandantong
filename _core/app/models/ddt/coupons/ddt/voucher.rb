module Ddt
  class Voucher < Ddt::BaseCoupon
    include BaseCouponConcern::SellableCoupon
    belongs_to :voucher_version, ->{with_discarded}, class_name: 'Ddt::VoucherVersion', foreign_key: :abstract_coupon_version_id
    delegate :branches, :branch_names, :value_desc, to: :voucher_version

    def exchange_detail
      self.voucher_version.name_with_items
    end

    def after_exchange
      self.touch(:applied_at)
      self.voucher_version.increment!(:used_coupons_count)
    end

    def can_exchange?(in_branch)
      !exchanged? && usable? && branches.include?(in_branch)
    end

    def can_apply?(order)
      !self.expired? and !self.applied? and order.active?
    end

    def set_applied(order, operator)
      self.update(applied_to_order_id: order.id, applied_in_branch_id: order.branch_id,operator: operator, applied_at: Time.now)
    end

    def rollback_voucher
      self.update_columns(applied_to_order_id: nil, applied_at: nil)
    end

    concerning :AdjustSource do
      included do
        def compute_amount_of_adjustment(order)
          -([self.abstract_coupon_version.norminal_value, order.total].min)
        end

        def get_label_of_adjustment(order)
          self.abstract_coupon_version.name
        end
      end
    end

    def weixin_show_path
      "weixin/shops/#{self.shop_id}/my?_ng_path=/user/vouchers"
    end
    url_method_for :weixin_show
  end
end
