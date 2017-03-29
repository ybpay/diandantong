class ChangeShift < ActiveRecord::Migration
  def change
    rename_column :ddt_shifts, :total_delete_itemable_amount, :total_subtract_item_amount
    rename_column :ddt_shifts, :delete_itemable_count, :subtract_item_count
  end
end
