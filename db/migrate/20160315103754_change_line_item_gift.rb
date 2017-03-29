class ChangeLineItemGift < ActiveRecord::Migration
  def change
    Ddt::LineItem.where(is_subtract: nil).update_all(is_subtract: false)
    change_column :ddt_line_items, :gift, :boolean, default: false, null: false
    change_column :ddt_line_items, :is_subtract, :boolean, default: false, null: false
  end
end
