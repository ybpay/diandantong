module Ddt
  class Notification
    module Action
      class Weixin < Ddt::NotificationAction
        include Ddt::SendTemplateMessage
        alias_method :user, :target

        def perform
          view = Ddt::Notification::View::Weixin.new(event, target)
          params = view.render
          if can_send_template_message?(view)
            access_token = @wechat_account.get_access_token
            user_open_id = @wechat_user.try(:user_open_id)
            params.delete(:title)
            params.delete(:description)
            params[:template_id] = @template_id
            if send_template_message(access_token, user_open_id, params)
              Ddt::WechatTemplateId.mark(@wechat_account.id, @template_id, :success)
            else
              Ddt::WechatTemplateId.mark(@wechat_account.id, @template_id, :fail)
              send_customer_message(view.to_customer_message_params(params))
            end
          else
            params = view.to_customer_message_params(params) if view.template_id_short.present?
            send_customer_message(params)
          end
        end

        def send_customer_message(material_options)
          self.shop.notify_to(user, material_options)
        end

        def can_send_template_message?(view)
          return false if view.template_id_short.blank?
          @wechat_user = user.try(:primary_wechat_user)
          return false if @wechat_user.blank? || !@wechat_user.subscribed?
          @wechat_account = user.shop.primary_wechat_account
          @template_id = @wechat_account.get_template_id(view.template_id_short)
          return false if @template_id.blank?
          return true
        end

      end
    end
  end
end
