class AddRechargeRefund < ActiveRecord::Migration
  def change
    create_table :ddt_recharge_refunds do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :order, index: true
      t.references :vip_info, index: true
      t.references :operator, index: true
      t.string :order_number
      t.integer :credits, default: 0
      t.decimal :amount, precision: 10, scale: 2, default: 0.0
      t.decimal :cash_amount, precision: 10, scale: 2, default: 0.0
      t.decimal :extra_amount, precision: 10, scale: 2, default: 0.0
      t.string :state
      t.timestamps
    end
  end
end
