class AddOrderStatToShift < ActiveRecord::Migration
  def change
    add_column :ddt_shifts, :pending_orders_before, :integer, default: 0
    add_column :ddt_shifts, :pending_orders_after, :integer, default: 0

    add_column :ddt_shifts, :confirmed_orders_before, :integer, default: 0
    add_column :ddt_shifts, :confirmed_orders_after, :integer, default: 0

    add_column :ddt_shifts, :completed_orders_before, :integer, default: 0
    add_column :ddt_shifts, :completed_orders_after, :integer, default: 0
  end
end
