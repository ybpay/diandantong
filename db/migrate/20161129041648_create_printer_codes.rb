class CreatePrinterCodes < ActiveRecord::Migration
  def change
    create_table :ddt_printer_codes do |t|
      t.integer 'shop_id'
      t.string 'code'
      t.string 'secret'
      t.timestamps
    end
  end
end
