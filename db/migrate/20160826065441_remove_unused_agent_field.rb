class RemoveUnusedAgentField < ActiveRecord::Migration
  def change
    remove_column :ddt_agents, :mini_store_price
    remove_column :ddt_agents, :standard_store_price
    remove_column :ddt_agents, :multiple_store_price
    remove_column :ddt_agents, :chain_start_price
    remove_column :ddt_agents, :increase_per_store_cost
    remove_column :ddt_agents, :chain_start_num
  end
end
