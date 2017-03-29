#encoding: utf-8
module Ddt
  class WechatTemplateId < Ddt::Base
    replicated_model

    belongs_to :wechat_account, class_name: "Ddt::WechatAccount"
    validates_presence_of :wechat_account_id, :template_id_short

    # 允许连续失败8次
    FAIL_LIMIT = 8

    # 当前状态可以用来发送
    def can_send?
      template_id.present? && ([nil] + (0...FAIL_LIMIT).to_a).include?(failed_count)
    end

    def can_retry?
      Time.now - updated_at >= 1.day.to_i
    end

    def over_fail_limit?
      failed_count >= FAIL_LIMIT
    end




    class << self

      def get_template_id(wechat_account, template_id_short)
        return nil unless wechat_account.account_verified_service?
        wechat_template_id = wechat_account.wechat_template_ids.find_by(template_id_short: template_id_short)
        return wechat_template_id.template_id if wechat_template_id.present? && wechat_template_id.can_send?

        if wechat_template_id.present?
          # 不可重试, 并且失败超限制， 不在尝试
          return nil if !wechat_template_id.can_retry? && wechat_template_id.over_fail_limit?
          wechat_template_id.failed_count = 0 if wechat_template_id.can_retry?
          template_id = create_template_id(wechat_account.get_access_token, template_id_short)
          failed_count = template_id.present? ? 0: (wechat_template_id.failed_count+1 rescue 1)
          wechat_template_id.update(template_id: template_id, failed_count: failed_count)
          template_id
        else
          template_id = create_template_id(wechat_account.get_access_token, template_id_short)
          wechat_template_id = wechat_account.wechat_template_ids.create!(template_id_short: template_id_short, template_id: template_id, failed_count: (template_id.present? ? 0: 1))
          template_id
        end

      end

      def create_template_id(access_token, template_id_short)
        Ddt::WeixinApi.add_template(access_token, template_id_short) rescue nil
      end

      # params @result :success or :fail
      def mark(wechat_account_id, template_id, result)
        wechat_template_id = self.find_by(wechat_account_id: wechat_account_id, template_id: template_id)
        if wechat_template_id.present?
          case result
          when :success
            if wechat_template_id.failed_count != 0
              wechat_template_id.update(failed_count: 0)
            end
          when :fail
            wechat_template_id.update(failed_count: (wechat_template_id.failed_count+1 rescue 1) )
          end
        end
      end

    end

  end
end
