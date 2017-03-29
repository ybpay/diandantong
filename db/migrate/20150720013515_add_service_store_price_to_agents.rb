class AddServiceStorePriceToAgents < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_agents, :service_store_price
      add_column :ddt_agents, :service_store_price, :integer, default: 658
      rename_column :ddt_agents, :single_price, :single_store_price
      rename_column :ddt_agents, :multiple_price, :multiple_store_price
    end
  end
end
