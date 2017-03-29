class CreateShift < ActiveRecord::Migration
  def change
    add_column :ddt_orders, :amount_for_pay, :decimal, precision: 8, scale: 2
    add_index :ddt_orders, :completed_at
    create_table :ddt_shifts do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :account, index: true
      t.decimal :initial_amount, precision: 8, scale: 2
      t.decimal :turnover_amount, precision: 8, scale: 2
      t.decimal :final_amount, precision: 8, scale: 2
      t.decimal :alipay_amount, precision: 8, scale: 2
      t.decimal :wechatpay_amount, precision: 8, scale: 2
      t.decimal :baidupay_amount, precision: 8, scale: 2
      t.decimal :vip_card_pay_amount, precision: 8, scale: 2
      t.decimal :bank_card_pay_amount, precision: 8, scale: 2
      t.decimal :total_amount, precision: 8, scale: 2
      t.string :state, default: 'opening'
      t.datetime :closed_at
      t.timestamps
    end
    add_index :ddt_shifts, :state
    add_index :ddt_shifts, :closed_at
  end
end
