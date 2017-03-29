class AddAdjustReasonToLineItem < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :adjust_reason, :string, default: "none"
    add_column :ddt_orders, :disable_discount_amount, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
