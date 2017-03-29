class CreatePrintTimes < ActiveRecord::Migration
  def change
    create_table :ddt_print_times do |t|
      t.integer :order_id
      t.integer :consume_bill_times, default: 0
      t.integer :bill_times, default: 0
    end
    add_index :ddt_print_times, :order_id
  end
end
