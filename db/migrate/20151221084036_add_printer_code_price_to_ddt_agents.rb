class AddPrinterCodePriceToDdtAgents < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :db_printer_code_price, :integer
    Ddt::Agent.update_all(db_printer_code_price: 100)
  end
end
