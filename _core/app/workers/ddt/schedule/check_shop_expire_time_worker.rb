#encoding: utf-8
module Ddt
  module Schedule
    class CheckShopExpireTimeWorker < Ddt::Schedule::Base
      attr_accessor :result

      def perform
        Ddt::Shop.where(expiration_time: Time.now..1.day.from_now, created_at: 1.month.ago..Time.now).each do |shop|
          push_to_result(shop, :expire_soon)
          body = "您的#{shop.support_brand_name}帐号将于#{shop.expiration_time.strftime('%F %T')}到期，为了避免影响您的正常使用，请联系#{shop.is_oem? ? shop.prepaid_phone : '18616250389'}进行续费充值。"
          Ddt::SmsProvider::Cl2009.send(shop.telephone, body)
        end
        Ddt::Shop.where(expiration_time: 7.days.from_now..14.days.from_now).where("created_at < ?", 1.month.ago).each do |shop|
          push_to_result(shop, :expire_weeks_later)
          body = "您的#{shop.support_brand_name}帐号将于#{shop.expiration_time.strftime('%F %T')}到期，为了避免影响您的正常使用，请联系#{shop.is_oem? ? shop.prepaid_phone : '18616250389'}进行续费充值。"
          Ddt::SmsProvider::Cl2009.send(shop.telephone, body)
          BaseMailer.notify(Rails.application.config.salers_mail, "[续费提醒] #{shop.support_brand_name} #{shop.slug} #{shop.id}", "#{shop.support_brand_name}帐号#{shop.name}(联系信息：#{shop.phone})将于#{shop.expiration_time.strftime('%F %T')}到期, 请联系#{shop.is_oem? ? shop.prepaid_phone : '18616250389'}进行续费充值。")
        end


        Ddt::Shop.where(expiration_time: 7.day.ago..Time.now).each do |shop|
          push_to_result(shop, :expired)
          body = "您的#{shop.support_brand_name}帐号已经到期，为了避免影响您的正常使用，请联系#{shop.is_oem? ? shop.prepaid_phone : '18616250389'}进行续费充值。"
          Ddt::SmsProvider::Cl2009.send(shop.telephone, body)
        end

        send_email_to_agent if @result.present?
      end

      def push_to_result(shop, key)
        # { agent_no: {expire_soon: [], expire_weeks_later: [], expired: []} }
        agent_no = shop.agent_no
        return if agent_no.blank? || shop.is_give_up
        @result = {} if @result.blank?
        @result[agent_no] = {} if @result[agent_no].blank?
        @result[agent_no][key] = [] if @result[agent_no][key].blank?
        @result[agent_no][key] << shop
      end

      def send_email_to_agent
        @result.each do |agent_no, value|
          agent = Ddt::Agent.find_by(agent_no: agent_no)
          return if agent.blank? || agent.email.blank?
          body = []
          body << get_email_content(value[:expire_weeks_later], '[客户帐号即将到期通知](近30天注册, 1天内将过期)')
          body << get_email_content(value[:expire_soon], '[客户帐号即将到期通知](两周内将过期)')
          body << get_email_content(value[:expired], '[客户帐号过期通知](近7天过期的)')
          content = body.map{|part| part.join("\n")}.join("\n\n")
          content << "\n 如某些客户您不需要再跟进， 可在代理后台标记， 系统将不再提醒已标记的客户"
          BaseMailer.notify(agent.email, "[客户跟进提醒]", content)
        end
      end

      def get_email_content(shops, type)
        return [] if shops.blank?
        body = []
        body << "类型: #{type}"
        body << "详细如下:"
        shops.each do |shop|
          body << "#{shop.support_brand_name}-#{shop.name}, 过期时间: #{shop.expiration_time.strftime('%F %T')}, 联系方式: #{shop.telephone}"
        end
        body
      end

    end
  end
end
