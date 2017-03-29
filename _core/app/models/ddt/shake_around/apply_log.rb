#encoding: utf-8
module Ddt
  module ShakeAround
    class ApplyLog < Ddt::Base
      # quantity
      # apply_id
      # apply_reason
      # apply_time
      # comment
      # poi_id
      # audit_status
      # audit_comment
      # audit_time
      # shop_id
      # wechat_account_id

      belongs_to :shop, class_name: 'Ddt::Shop'
      belongs_to :wechat_account, class_name: 'Ddt::WechatAccount'
      set_from :wechat_account, targets: [:shop_id]
      has_many :devices, class_name: 'Ddt::ShakeAround::Device'

      STATUS_LABELS = %W[审核未通过 审核中 审核已通过]
      validates :quantity, presence: true, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: 500}
      validates_presence_of :apply_reason, :wechat_account_id
      validates_length_of :comment, maximum: 30, tokenizer: ->(str) { (1..str.width).to_a }, if: :comment_present?

      before_create :apply_device
      after_find :sync_apply_result

      scope :appling, ->{ where(audit_status: 1)}

      def comment_present?
        self.comment.present?
      end

      def audit_status_name
        STATUS_LABELS[audit_status]
      end

      def access_token
        @access_token ||= wechat_account.get_access_token
      end

      private

        def apply_device
          unless self.errors.any?
            if wechat_account.apply_device_logs.appling.count == 0
              result = Ddt::WeixinApi.device_apply_id(access_token, quantity, apply_reason, self.comment, self.poi_id)
              self.attributes = self.attributes.merge! result
            else
              self.errors.add(:base, "您正在申请设备ID, 请不要重复申请")
            end
          end
        end

        def sync_apply_result
          if self.audit_status == 1
            result = Ddt::WeixinApi.device_apply_status(access_token, self.apply_id)
            self.update! result
          end
        end

    end
  end
end
