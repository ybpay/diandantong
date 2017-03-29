class AddPlocyVersionToAgents < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :plocy_version, :string
    version = "VERSION_1_#{Time.now.strftime('%Y-%m-%d')}"
    Ddt::Agent.with_deleted.update_all(plocy_version: version)
  end
end
