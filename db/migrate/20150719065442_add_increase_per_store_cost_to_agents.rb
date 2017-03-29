class AddIncreasePerStoreCostToAgents < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_agents, :increase_per_store_cost
      add_column :ddt_agents, :increase_per_store_cost, :integer, default: 350
    end
  end
end
