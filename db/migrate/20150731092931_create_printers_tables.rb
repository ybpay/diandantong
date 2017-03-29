class CreatePrintersTables < ActiveRecord::Migration
  def change
    create_table :ddt_printers_tables, id: false do |t|
      t.references :printer, index: true
      t.references :table, index: true
    end
  end
end
