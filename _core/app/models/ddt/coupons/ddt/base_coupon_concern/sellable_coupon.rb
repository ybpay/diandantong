module Ddt
  module BaseCouponConcern
    module SellableCoupon
      extend ActiveSupport::Concern
      included do
        belongs_to_order name: :bought_from_order, foreign_key: :bought_from_order_id
        scope :refund, ->{ where.not(refund_at: nil)}
        scope :not_refund, ->{ where(refund_at: nil)}
        def refund?
          self.refund_at.present?
        end

        def can_apply_refund?
          self.support_refund &&
          self.refund_at.nil? &&
          self.applied_at.nil? &&
          !self.applying_refund &&
          (self.created_at + self.refundable_days_after_send.days > Time.now)
        end

        def can_refund?
          self.support_refund &&
          self.refund_at.nil? &&
          self.applied_at.nil? &&
          self.applying_refund &&
          (self.created_at + self.refundable_days_after_send.days > Time.now)
        end

        def refund_coupon
          if can_refund?
            ActiveRecord::Base.transaction do
              self.update(refund_at: Time.now, applying_refund: false)
              self.abstract_coupon_version.increment!(:refund_coupons_count)
              self.order_ext.update!(refunded_amount: self.abstract_coupon_version.groupon_price)
              self.bought_from_order.save
              Ddt::Notification::Event::Coupon::Refund.create_and_send_notification(base_coupon: self, order: self.bought_from_order)
              return true
            end
            return false
          end
        end

        def apply_refund
          if can_apply_refund?
            self.update(applying_refund: true)
            Ddt::Notification::Event::Coupon::ApplyingRefund.create_and_send_notification(base_coupon: self, order: self.bought_from_order)
            return true
          end
          return false
        end

        def cancel_apply_refund
          if self.applying_refund
            self.update(applying_refund: false)
            Ddt::Notification::Event::Coupon::CancelApplyingRefund.create_and_send_notification(base_coupon: self, order: self.bought_from_order)
          else
            return false
          end
        end

        def order_ext
          Ddt::OrderExt.find_by(order_id: bought_from_order_id)
        end

      end

      module ClassMethods
      end
    end
  end
end
