class AddChainStartPriceToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :chain_start_price, :decimal, scale: 2, precision: 8
    add_column :ddt_agents, :chain_start_num, :integer, default: 2
  end
end
