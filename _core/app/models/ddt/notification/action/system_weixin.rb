module Ddt
  class Notification
    module Action
      class SystemWeixin < Ddt::NotificationAction
        include Ddt::SendTemplateMessage
        alias_method :account, :target
        def perform
          message = Ddt::Notification::View::SystemWeixin.new(event, target).render
          return if message.blank?
          user_open_id = nil
          if self.shop.is_custom_system_weixin_notification
            wechat_user = account.try(:user).try(:primary_wechat_user)
            #只有对当前已经关注的用户才下发微信模板消息
            if wechat_user && wechat_user.subscribed?
              user_open_id = wechat_user.try(:user_open_id)
            end
            access_token = self.shop.primary_wechat_account.get_access_token
          else
            #TODO:此处未来需要判断是否用户已经关注
            user_open_id = account.try(:user_open_id)
            access_token = Ddt::WechatAccount.system_wechat_account.get_access_token
          end

          send_template_message(access_token, user_open_id, message)
        end
      end
    end
  end
end
