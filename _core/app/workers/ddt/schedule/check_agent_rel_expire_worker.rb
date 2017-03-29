# encoding: utf-8
module Ddt
  module Schedule
    class CheckAgentRelExpireWorker < Ddt::Schedule::Base

      def perform
        now = Time.now

        expired_agent_rels = []
        release_agent_rels = []
        expired_soon_agent_rels = []

        Ddt::AgentRel.where(agent_to: 7.days.ago..now).find_each do |agent_rel|
          send_expired_soon_email_to_agent(agent_rel)
        end

        Ddt::AgentRel.where("agent_to < :now", now: now).find_each do |agent_rel|
          if now - 1.month > agent_rel.agent_to
            release_agent_rels << agent_rel
          else
            expired_agent_rels << agent_rel
            send_expired_email_to_agent(agent_rel)
          end
        end

        send_email_to_admin(expired_agent_rels, "[代理关系过期通知]") if expired_agent_rels.present?
        send_email_to_admin(release_agent_rels, "[代理资源请求释放名单]") if release_agent_rels.present?
      end


      private

        def send_expired_soon_email_to_agent(agent_rel)
          body = []
          msg = get_agent_msg(agent_rel)
          body << "尊敬的#{agent_rel.agent.name}， 您好。"
          body << "您在#{msg[:agent_zone_name]}的代理期限即将过期, 如需续约请与我们公司联系。"
          body << "如过期后一个月内未联系本公司进行续费, 您在#{msg[:agent_zone_name]}开发的客户将被释放回收。"
          BaseMailer.notify(agent_rel.agent.email, "[代理关系即将过期通知]", body.join("\n"))
        end

        def send_expired_email_to_agent(agent_rel)
          body = []
          msg = get_agent_msg(agent_rel)
          body << "尊敬的#{agent_rel.agent.name}， 您好。"
          body << "您在#{msg[:agent_zone_name]}的代理期限已经过期， 您在该区域的代理权限已被冻结。 如需续约请与我们公司联系。"
          body << "如一个月内未联系本公司进行续费, 您在#{msg[:agent_zone_name]}开发的客户将被释放回收。"
          BaseMailer.notify(agent_rel.agent.email, "[代理关系过期通知]", body.join("\n"))
        end

        def send_email_to_admin(agent_rels, email_title)
          body = []
          agent_rels.map do |rel|
            msg = get_agent_msg(rel)
            body << "代理时间 #{msg[:agent_from]} ~ #{msg[:agent_to]} , 代理商 #{rel.agent.name}(#{rel.agent.id}),联系方式：#{rel.agent.phone}, 代理区域 #{msg[:agent_zone_name]}"
          end
          BaseMailer.notify(Rails.application.config.supervisor_mail, email_title, body.join("\n"))
        end

        def get_agent_msg(agent_rel)
          {
            agent_from: agent_rel.agent_from.strftime('%Y-%m-%d %H:%M'),
            agent_to:   agent_rel.agent_to.strftime('%Y-%m-%d %H:%M'),
            agent_zone_name: agent_rel.agent_zone.name_with_parent
          }
        end

    end
  end
end
