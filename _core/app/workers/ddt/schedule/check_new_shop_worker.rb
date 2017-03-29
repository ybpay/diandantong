module Ddt
  module Schedule
    class CheckNewShopWorker < Ddt::Schedule::Base
      include Sidekiq::Worker
      include Ddt::Color
      include Ddt::SendTemplateMessage

      attr_accessor :agent_shops, :ddb_shops

      def perform
        yesterday = 1.day.ago.beginning_of_day..1.day.ago.end_of_day
        Ddt::Shop.where(created_at: yesterday).find_each do |shop|
          push_to_ddb_shops(shop)
          if shop.agent_no.present?
            push_to_agent_shops(shop)
          end
        end
        send_email_to_agent if @agent_shops.present?
        send_email_to_ddb if @ddb_shops.present?
      end

      private

        def push_to_agent_shops(shop)
          # agent_shops: {agent_no: [shops]}
          agent_no = shop.agent_no
          @agent_shops = {} if @agent_shops.blank?
          @agent_shops[agent_no] = [] if @agent_shops[agent_no].blank?
          @agent_shops[agent_no] << shop
        end

        def push_to_ddb_shops(shop)
          # ddb_shops: [shops]
          @ddb_shops = [] if @ddb_shops.blank?
          @ddb_shops << shop
        end

        def send_email_to_agent
          @agent_shops.each do |agent_no, shops|
            agent = Ddt::Agent.find_by(agent_no: agent_no)
            return if agent.blank? || agent.email.blank?
            BaseMailer.notify(agent.email, "[昨日新注册用户]", get_msg_content(shops, :detail))
          end
        end

        # def send_wechat_msg_to_agent
        #   #新增模板审核没通过, 暂不通知
        #   template_id = Ddt::WeixinConfig.template_id.new_client
        #   @agent_shops.each do |agent_no, shops|
        #     agent = Ddt::Agent.find_by(agent_no: agent_no)
        #     return if agent.blank?
        #     user_open_id = account.try(:user_open_id)
        #     access_token = Ddt::WechatAccount.system_wechat_account.get_access_token
        #     #
        #     data = {
        #       topcolor: green,
        #       first: '昨日新增客户情况',
        #       keyword1: '昨天',
        #       keyword2: "#{shops.size}人",
        #       remark: "详细如下\n#{get_msg_content(shops, :short)}"
        #     }
        #     message = {template_id: template_id, url: '', data: data}
        #     send_template_message(access_token, user_open_id, message)
        #   end

        # end

        def send_email_to_ddb
          BaseMailer.notify(Rails.application.config.supervisor_mail, "[昨日新注册用户]", get_msg_content(@ddb_shops, :detail))
        end

        def get_msg_content(shops, version)
          body = []
          shops.each do |shop|
            if version == :detail
              body << "代理商邀请码: #{shop.agent_no}, 商铺: #{shop.support_brand_name}-#{shop.name}, 注册时间#{shop.created_at.strftime('%F %T')}, 联系方式: #{shop.phone}"
            else
              body << "#{shop.name}(#{shop.phone})"
            end
          end
          body.join("\n")
        end

    end
  end
end
