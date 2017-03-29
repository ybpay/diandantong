class AddMiniStorePriceToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :mini_store_price, :decimal, scale: 2, precision: 8
    add_column :ddt_agents, :standard_store_price, :decimal, scale: 2, precision: 8
  end
end
