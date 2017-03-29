class AddNotActualAmountToLineItem < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :not_actual_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
