class AddCanSaleMultipleStoreToAgent < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_agents, :can_sale_multiple_store
      add_column :ddt_agents, :can_sale_multiple_store, :boolean, default: false
    end
  end
end
