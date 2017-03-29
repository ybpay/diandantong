class CreateOrderExt < ActiveRecord::Migration
  def change
    create_table :ddt_order_exts do |t|
      t.references :order, index: true
      t.boolean :ban_selfpay, default: false
      t.timestamps
    end
  end
end
