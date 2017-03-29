class CreateOtherVouchers < ActiveRecord::Migration
  def change
    create_table :ddt_other_vouchers do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :order, index: true
      t.string :from_platform
      t.decimal :amount, precision: 8, scale: 2
      t.string :number
      t.timestamps
    end
    add_index :ddt_other_vouchers, :created_at
  end
end
