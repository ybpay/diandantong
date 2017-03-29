class CreateDdtPrintersBanProducts < ActiveRecord::Migration
  def change
    create_table :ddt_printers_ban_products, id: false do |t|
      t.integer :printer_id
      t.integer :product_id
    end
    add_index :ddt_printers_ban_products, :printer_id, name: 'dpbp_printer_id'
    add_index :ddt_printers_ban_products, :product_id, name: 'dpbp_product_id'
  end
end
