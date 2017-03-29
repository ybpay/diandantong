class AddTotalDeleteItemableAmountToShift < ActiveRecord::Migration
  def change
    add_column :ddt_shifts, :total_delete_itemable_amount, :decimal, scale: 2, precision: 8
    add_column :ddt_shifts, :delete_itemable_count, :integer
  end
end
