# encoding: utf-8
module Ddt
  class CheckRegisterCompleteWorker < Ddt::Schedule::Base
    include Sidekiq::Worker
    sidekiq_options :retry => 5, :queue => :normal
    def perform(register_form_id)
      register_form = Ddt::RegisterForm.find(register_form_id)
      if register_form.shop_id.blank?
        logger.info "注册表单#{register_form_id}未能成功提交，发送邮件中..."
        send_mail_to_sales(register_form)
      else
        logger.info "注册表单#{register_form_id}成功提交"
      end
    end

    def send_mail_to_sales(register_form)
      content = "客户手机：#{register_form.phone}\n客户邮箱：#{register_form.email}\n客户用户名：#{register_form.login_id}\n注册来源：#{register_form.track_from_name}\n代理商编号：#{register_form.shop_agent_no}"
      content += "客户试图在#{register_form.created_at}注册后台试用，但是因为未知原因放弃注册，请联系客户进行跟进"
      email_to = "sales@diandantong.com"
      if register_form.shop_agent_no.present?
        agent = (Ddt::Agent.find_by(agent_no: register_form.shop_agent_no) rescue nil) 
        email_to = agent.email if agent.present?
      end
      BaseMailer.notify(email_to, "[有新客户注册未成功，请跟进了解]", content)
    end
  end
end
