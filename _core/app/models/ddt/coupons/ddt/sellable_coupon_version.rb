# encoding:utf-8
module Ddt
  module SellableCouponVersion
    extend ActiveSupport::Concern
    included do
      ### validations
      access_with_shop_time_zone :sellable_starts_at, :sellable_expires_at
      validates :sellable_starts_at, :sellable_expires_at, :groupon_price, presence: true
      validate :sellable_time_should_after_start
      after_save :touch_branch
      after_destroy :touch_branch

      def on_sale?
        ( sellable_starts_at.present? && Time.now >= sellable_starts_at) &&
        (sellable_expires_at.present? && Time.now <= sellable_expires_at)
      end

      concerning :ItemableMethod do
        include Itemable
        included do
          # column : name
          def sku
          end

          def itemable_name
            name_with_items || name
          end
          alias_method :product_name, :itemable_name

          def stock_quantity
            (max_grant_limit - base_coupons_count + refund_coupons_count)
          end

          def stock_enough?(require_num=1)
             stock_quantity >= require_num
          end

          def original_price
            self.norminal_value
          end

          def price
            self.groupon_price
          end

          def vip_price
            self.groupon_price
          end

          def unit_name
            '张'
          end

          def avatar_url
            self.coupon_photos.first.try(:image).try(:thumb_square).try(:url)
          end
        end
      end

      private

      def sellable_time_should_after_start
        self.errors.add(:sellable_starts_at, I18n.t('expire time should after start')) if self.sellable_starts_at.present? && self.sellable_expires_at && (self.sellable_starts_at > self.sellable_expires_at)
      end

      def touch_branch
        Ddt::Branch.find_by(id: self.branch_id).try(:touch) if self.branch_id.present?
        Ddt::Branch.find_by(id: self.branch_id_was).try(:touch) if self.branch_id_changed? && self.branch_id_was.present?
      end
    end

    module ClassMethods
    end



  end
end
