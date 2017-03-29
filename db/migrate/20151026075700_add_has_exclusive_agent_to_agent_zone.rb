class AddHasExclusiveAgentToAgentZone < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_agent_zones, :has_exclusive_agent
      add_column :ddt_agent_zones, :has_exclusive_agent, :boolean, default: false
    end
    Ddt::AgentRel.find_each do |rel|
      rel.set_exclusive_zone
    end
  end
end
