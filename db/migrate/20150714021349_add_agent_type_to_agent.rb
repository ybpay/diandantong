class AddAgentTypeToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :agent_type, :string, default: :normal_level
    add_column :ddt_agents, :exclusive, :boolean, default: false
    add_column :ddt_shops, :agent_zone_id, :integer
    add_index :ddt_shops, :agent_zone_id
  end
end
