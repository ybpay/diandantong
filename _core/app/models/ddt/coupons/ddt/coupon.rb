module Ddt
  class Coupon < Ddt::BaseCoupon

    belongs_to :coupon_version,  ->{with_discarded}, class_name: 'Ddt::CouponVersion', foreign_key: :abstract_coupon_version_id
    delegate :coupon_min_usable_amount,
             :product_sku, :product_skus,
             :coupon_type, :coupon_type_name, :is_amount_match?, :is_product_match?, :is_product_low_price_match?, :value_desc,
             :norminal_value,
             :can_use_in_branch?,
             :support_delivery?, :support_eat_in_hall?, :support_delivery, :support_eat_in_hall,
             to: :coupon_version

    def set_expires_at
      if self.expires_at.blank?
        if self.coupon_version.present? && self.coupon_version.is_after_send_expired_time?
          self.expires_at = self.coupon_version.usable_days_after_send.days.since.end_of_day
        else
          super
        end
      end
    end

    def usable?
      self.expires_at.present? && self.expires_at >= Time.now
    end

    def exchange_detail
      self.coupon_version.name_with_items
    end

    def can_exchange?(branch)
      @branch = branch
      !exchanged? && !applied? && !expired? && usable? && can_use_in_branch?(@branch)
    end

    def after_exchange
      exchange_code.branch = @branch
      exchange_code.save!
      self.touch(:applied_at)
      self.coupon_version.increment!(:used_coupons_count)
    end

    # 检查优惠券是否可以用在 order 上
    def can_apply?(order, with_error: false)
      if with_error
        self.errors[:base] << "优惠券已过期" if self.expired?
        self.errors[:base] << "优惠券已使用" if self.applied?
        self.errors[:base] << "订单状态不可用" if !(order.cart? || order.active?)
        self.errors[:base] << "不满足优惠券使用规则" if !satisfy?(order)
        self.errors.blank?
      else
        not self.expired? and
          not self.applied? and
          order.cart? || order.active? and
          satisfy?(order)
      end
    end

    def set_applied(order, operator)
      self.update(applied_to_order_id: order.id, applied_in_branch_id: order.branch_id,operator: operator, applied_at: Time.now)
    end

    #
    # 只处理回滚，是否满足回滚条件，由调用者负责
    #
    def rollback_coupon
      self.update(applied_to_order_id: nil, applied_at: nil)
    end

    def satisfy?(order)
      self.coupon_version.try(:satisfy_policy?, order)
    end

    def dissatisfaction(order)
      self.rollback_coupon
    end

    concerning :AdjustSource do
      included do
        def compute_amount_of_adjustment(order)
          if is_amount_match?
            -([norminal_value, order.total].min)
          elsif is_product_match?
            -order.line_items.active.select{|line_item| product_skus.include?(line_item.sku)}.map(&:price).min
          elsif is_product_low_price_match? && order.line_items.active.select{|line_item| product_skus.include?(line_item.sku)}.count > 0
            -([norminal_value, order.total].min)
          end
        end

        def get_label_of_adjustment(order)
          self.abstract_coupon_version.name
        end

        def get_item_adjustments(order)
          if is_product_match?
            line_item = order.line_items.active.select{|line_item| product_skus.include?(line_item.sku)}.min_by(&:price)
            item_adjustment = line_item.get_item_adjustment(-line_item.price)
            [item_adjustment]
          end
        end

        def need_apportion_adjustment_amount?
          is_amount_match?
        end
      end
    end


    def weixin_show_path
      "weixin/shops/#{self.shop_id}/my?_ng_path=/user/coupons"
    end
    url_method_for :weixin_show

  end
end
