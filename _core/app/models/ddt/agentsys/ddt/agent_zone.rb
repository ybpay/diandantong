# encoding: utf-8
module Ddt
  class AgentZone < ActiveRecord::Base
    ### relationships
    has_many :agent_rels
    has_many :agents, through: :agent_rels
    belongs_to :parent_agent_zone, class_name: 'Ddt::AgentZone'
    has_many :sub_agent_zones, dependent: :destroy, class_name: 'Ddt::AgentZone', foreign_key: :parent_agent_zone_id

    ### validations
    validates :name, presence: true
    validates :full_name, presence: true

    ### callbacks

    ### scopes
    scope :root_agent_zones, -> { where(:parent_agent_zone_id=>nil) }

    before_save :assign_city_code

    def all_sub_ids
      [self.id, self.sub_agent_zones.map{|sub| [sub.id, sub.sub_agent_zones.pluck(:id)]}].flatten.uniq
    end

    def agents_count
      self.agents.count + self.sub_agent_zones.to_a.sum{ |agent_zone| agent_zone.agents_count}
    end

    def update_name_recur(name)
      if self.name != name
        transaction do
          parent_full_name = if self.full_name == self.name
            nil
          else
            self.full_name.split('-')[0..-2].join('-')
          end

          self.update!(name: name)
          self.update_full_name_recur(parent_full_name)
        end
      end
    end

    def update_full_name_recur(parent_full_name)
      full_name = if parent_full_name.nil?
        self.name
      else
        [parent_full_name, self.name].join('-')
      end
      self.update!(full_name: full_name)
      self.sub_agent_zones.each do |sub|
        sub.update_full_name_recur(self.full_name)
      end
    end

    def self.create_linkage_zones_with_full_name(full_name)
      names = full_name.split('-')
      create_linkage_zones(names, nil)
    end

    def self.create_linkage_zones(names, parent_zone = nil)
      if names.empty?
        parent_zone
      else
        name = names.first
        full_name = parent_zone.nil? ? name : "#{parent_zone.full_name}-#{name}"
        zone = self.find_or_create_with_full_name!(name: name, full_name: full_name, parent_agent_zone: parent_zone)
        create_linkage_zones(names[1..-1], zone)
      end
    end

    def name_with_parent
      if self.parent_agent_zone.present?
        "#{self.parent_agent_zone.name_with_parent}-#{self.name}"
      else
        self.name
      end
    end

    def select_json
      { id: self.id, name: self.name_with_parent }
    end

    # 获取上级区域的独家代理
    def get_parent_zone_agent
      city_codes = Cncity.parse_code(self.city_code)
      city_codes.delete(self.city_code)
      self.class.get_first_exclusive_agent(city_codes)
    end

    # 根据城市编码查找独家代理商
    def self.get_exclusive_agent(city_code)
      get_first_exclusive_agent(Cncity.parse_code(city_code))
    end

    # 取得 city_codes 里的的一个独家代理商, 由下级往上级查找(如有多个，权重大的找到的概率大)
    def self.get_first_exclusive_agent(city_codes)
      return nil if city_codes.blank?
      zones = self.where(city_code: city_codes, has_exclusive_agent: true)
      return nil if zones.blank?
      zones = zones.sort{|a, b| a.city_code <=> b.city_code}.reverse
      zones[0].luckly_agent
    end

    def luckly_agent
      exclusive_agents = self.agents.where(exclusive: true)
      return nil if exclusive_agents.blank?
      return exclusive_agents[0] if exclusive_agents.size == 1

      rels = self.agent_rels.where(agent_id: exclusive_agents.map(&:id))
      key = rand(100) + 1
      head = 1
      tail = 1
      rels.detect do |rel|
        head = (head == 1 ? 1 : tail + 1)
        tail = (tail == 1 ? rel.weight : tail + rel.weight)
        (head..tail).include?(key)
      end.agent
    end

    private
    def self.find_or_create_with_full_name!(params)
      zone = self.find_by full_name: params[:full_name]
      zone or self.create!(params)
    end

    def assign_city_code
      if self.city_code.nil? || full_name_changed?
        self.city_code = Cncity.get_city_code(self.full_name)
      end
    end

  end
end
