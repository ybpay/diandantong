class AddIsAppendToPayItem < ActiveRecord::Migration
  def change
    add_column :ddt_pay_items, :is_append, :boolean, default: false
  end
end
