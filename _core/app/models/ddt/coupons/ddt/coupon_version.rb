#encoding: utf-8
module Ddt
  class CouponVersion < Ddt::AbstractCouponVersion
    has_many :coupons, class_name: 'Ddt::Coupon', foreign_key: :abstract_coupon_version_id
    acts_as_type :coupon_appliable_branch_scope_policy, [:appliable_to_any_branch, :appliable_to_part_branch], %W[门店通用 部分门店]
    validates :coupon_appliable_branch_scope_policy, presence: true
    validates :coupon_min_usable_amount, presence: true, if: :is_amount_match?
    validates :product_sku, presence: true, if: :is_product_match?
    validates :credit_count, presence: true, :numericality => {only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1000000} if :can_exchange?
    validates :norminal_value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 99990000.0}, if: :is_amount_match?
    has_many :sharable_coupons, class_name: 'Diandanban::SharableCoupon'
    has_many :get_coupon_actions, class_name: 'Ddt::Promotion::Actions::Event::GetCoupon', dependent: :destroy, foreign_key: :abstract_coupon_version_id
    has_many :get_sharable_coupon_actions, class_name: 'Ddt::Promotion::Actions::Event::GetSharableCoupon', dependent: :destroy, foreign_key: :abstract_coupon_version_id

    acts_as_type :coupon_type, [:amount_match, :product_match, :product_low_price_match], %W(满减优惠券 菜品优惠券 菜品减价优惠券), default: :amount_match
    #
    # 计算优惠券是否可用。
    # 价格计算为了避免计算顺序的影响，只取商品价格，不依赖于订单的其它价格调整
    #
    def satisfy_policy?(order)
      # 满足策略分店限制
      return false unless self.shop_id == order.shop_id
      return false unless can_use_in_branch?(order.branch)
      return false if order.is_delivery? && !self.support_delivery?
      return false if order.is_eat_in_hall? && !self.support_eat_in_hall?
      if is_amount_match?
        return order.item_total >= coupon_min_usable_amount
      elsif is_product_match? || is_product_low_price_match?
        return order.line_items.active.any?{|line_item| product_skus.include?(line_item.sku)}
      end
    end

    def product_skus
      @product_skus ||= self.product_sku.try(:split, ",") || []
    end

    def can_use_in_branch?(branch)
      if self.is_appliable_to_part_branch?
        return false unless self.branches.include?(branch)
      end
      return true
    end

    def name_with_items
      name
    end

    def branch_names
      self.branches.map(&:name).join(",")
    end

    def value_desc
      if is_amount_match?
        "#{self.norminal_value_in_currency} (满#{self.coupon_min_usable_amount_in_currency}可用)"
      elsif is_product_match?
        "#{self.product_sku}可用"
      end
    end

    # 用积分 兑换 券
    def exchange_by(user, num, note)
      Ddt::CouponVersion.transaction do
        if self.can_exchange? && can_receive_by?(user, num)
          credit_wallet = user.vip_info.credits_wallet
          require_amount = self.credit_count * num
          if credit_wallet.amount >= require_amount
            num.times do
              self.coupons.create!({
                base_user: user,
                track_from: :credit
              })
            end
            credit_wallet.exchange(require_amount, note: note)
            return true
          else
            self.errors[:base] << "您的积分不足， 无法兑换. "
            return false
          end
        else
          self.errors[:base] << "该券每人最多可获得#{self.max_count_each_user}"
          return false
        end
      end
    end

  end
end