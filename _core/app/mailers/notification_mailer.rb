class NotificationMailer < ActionMailer::Base
  def notify(to, subject, body, shop)
    # 平台OEM
    shop_oem_delivery_method_options = {}
    if shop.use_custom_brand
      email_setting = shop.email_setting
      if email_setting.address.present? && email_setting.user_name.present? && email_setting.password.present?
        shop_oem_delivery_method_options = {
          address:   email_setting.address,
          user_name: email_setting.user_name,
          password:  email_setting.password
        }
      end
    end
    # 代理OEM
    agent_oem_delivery_method_options = {}
    agent = shop.agent
    if agent.present? && agent.is_oem && agent.email_address.present? && agent.email_user_name.present? && agent.email_password.present?
      agent_oem_delivery_method_options = {
        address:   agent.email_address,
        user_name: agent.email_user_name,
        password:  agent.email_password
      }
    end
    if shop_oem_delivery_method_options.present?
      mail(to: to, from: "#{shop.name} <#{shop_oem_delivery_method_options[:user_name]}>", subject: subject, body: body, delivery_method_options: shop_oem_delivery_method_options)
    elsif agent_oem_delivery_method_options.present?
      mail(to: to, from: "#{agent.company_name} <#{agent_oem_delivery_method_options[:user_name]}>", subject: subject, body: body, delivery_method_options: agent_oem_delivery_method_options)
    else
      mail(to: to, subject: subject, body: body)
    end
  end
end