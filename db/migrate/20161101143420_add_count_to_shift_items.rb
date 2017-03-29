class AddCountToShiftItems < ActiveRecord::Migration
  def change
  	add_column :ddt_shift_items, :count, :integer
  end
end
