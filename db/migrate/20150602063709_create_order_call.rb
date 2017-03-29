class CreateOrderCall < ActiveRecord::Migration
  def change
    create_table :ddt_order_calls do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :order, index: true
      t.string :text
      t.string :to
      t.string :call_sid
      t.integer :state
      t.integer :duration
      t.string :user_data
      t.timestamps
    end

    add_index :ddt_order_calls, :call_sid
  end
end
