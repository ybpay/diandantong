class CreateCallSetting < ActiveRecord::Migration
  def change
    create_table :ddt_call_settings do |t|
      t.references :shop, index: true
      t.boolean :enable_order_call, default: true
      t.decimal :amount, precision: 8, scale: 2, default: 0.5
      t.decimal :used_amount, precision: 8, scale: 2, default: 0.0
      t.timestamps
    end
    count = 0
    Ddt::Shop.all.each_with_index do |shop, index|
      shop.create_call_setting!
      puts "shop index: #{index}" if index % 100 == 0
    end
  end
end
