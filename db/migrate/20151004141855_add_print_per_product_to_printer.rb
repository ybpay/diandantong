class AddPrintPerProductToPrinter < ActiveRecord::Migration
  def change
    add_column :ddt_printers, :print_per_product, :boolean, default: false
  end
end
