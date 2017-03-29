class AddDiscountPriceToAgentPrinters < ActiveRecord::Migration
  def change
    remove_column :ddt_agents, :db_printer_code_price
    add_column :ddt_agent_printers, :discount_price, :decimal, precision:10, scale: 2, default: 25
  end
end
