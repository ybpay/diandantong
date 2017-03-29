class AddTickAccount < ActiveRecord::Migration
  def up
    create_table :ddt_tick_accounts do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.string :name
      t.text :note
      t.boolean :enable, default: true
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :ddt_tick_account_items do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :tick_account, index: true
      t.string :tick_account_name
      t.references :order, index: true
      t.string :order_number
      t.references :pay_item, index: true
      t.decimal :amount, precision: 8, scale: 2
      t.string :state
      t.timestamps
    end

    add_column :ddt_pay_items, :tick_account_id, :integer
    add_column :ddt_pay_items, :tick_account_name, :string

    Ddt::Shop.all.find_each do |shop|
      shop.pay_methods.builtin.create({ name_sym: :tick_for_account, name: "挂账" })
    end
  end

  def down
    Ddt::PayMethod.where(name_sym: :tick_for_account).delete_all
    remove_column :ddt_pay_items, :tick_account_name, :string
    remove_column :ddt_pay_items, :tick_account_id, :integer
    drop_table :ddt_tick_account_items
    drop_table :ddt_tick_accounts
  end
end
