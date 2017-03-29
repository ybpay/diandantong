# encoding: utf-8
module Ddt
  class AgentRel < Ddt::Base

    ### relationships
    belongs_to :agent
    belongs_to :agent_zone

    ### validations
    validates_presence_of :agent_from, :agent_to, :agent_zone
    validates_uniqueness_of :agent_id, :scope=> :agent_zone_id
    validate :agent_from_lt_agent_to

    ### callbacks
    after_save :set_exclusive_zone
    # after_save :adjust_resource
    before_destroy :del_exclusive_zone


    # 释放代理资源
    def release
      agent = Ddt::Agent.with_deleted.find(self.agent_id)
      if agent.blank?
        self.destroy
        return
      end
      parent_agent = agent_zone.get_parent_zone_agent
      city_code_format = agent.city_code_format(agent_zone)
      if parent_agent.blank?
        # 无上级代理则资源归入公司
        move_resource(
          city_code_like: city_code_format,
          from_agent_no: agent.agent_no,
          to_agent_no: nil
        )
      else
        # 资源归入父级代理商
        move_resource(
          city_code_like: city_code_format,
          from_agent_no: agent.agent_no,
          to_agent_no: parent_agent.agent_no
        )
      end
      self.destroy
    end

    # 代理关系保存时， 如是独家代理，则调整资源
    # def adjust_resource
    #   if self.agent && self.agent.exclusive?

    #     city_code_format = self.agent.city_code_format(agent_zone)
    #     parent_agent = agent_zone.get_parent_zone_agent

    #     if parent_agent.present?
    #       # 父区域资源下放
    #       move_resource(
    #         city_code_like: city_code_format,
    #         from_agent_no: parent_agent.agent_no,
    #         to_agent_no: self.agent.agent_no
    #       )
    #     end

    #     # 绑定子区域资源
    #     bind_resource(
    #       city_code_like: city_code_format,
    #       to_agent_no: self.agent.agent_no
    #     )

    #   end
    # end

    def move_resource(city_code_like:, from_agent_no:, to_agent_no:)
      Ddt::Shop.where(
        'agent_no = ? AND city_code LIKE ?',
        from_agent_no,
        city_code_like
      ).update_all(agent_no: to_agent_no)
    end

    def bind_resource(city_code_like:, to_agent_no:)
      Ddt::Shop.where(
        'agent_no IS NULL AND city_code LIKE ?',
        city_code_like
      ).update_all(agent_no: to_agent_no)
    end

    def set_exclusive_zone
      if self.agent && self.agent.exclusive?
        agent_zone.update_columns(has_exclusive_agent: true)
      end
    end

    def del_exclusive_zone
      if agent_zone.agents.where(exclusive: true).blank?
        agent_zone.update_columns(has_exclusive_agent: false)
      end
    end

    private
    def agent_from_lt_agent_to
      if self.agent_from+1.day >= self.agent_to
        self.errors.add(:agent_from, "必须小于代理截止日期")
      end
    end

  end
end
