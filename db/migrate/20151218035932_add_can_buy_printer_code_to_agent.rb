class AddCanBuyPrinterCodeToAgent < ActiveRecord::Migration
  def change
    add_column :ddt_agents, :can_buy_printer_code, :boolean, default: false
    change_column :ddt_agents, :can_buy_printer_code, :boolean, default: true
  end
end
