class AddDiscountAmountAndMolingAmountToShift < ActiveRecord::Migration
  def change
    add_column :ddt_shifts, :discount_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_shifts, :moling_amount, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
