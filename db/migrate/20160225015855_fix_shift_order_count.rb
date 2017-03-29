class FixShiftOrderCount < ActiveRecord::Migration
  def change
    Ddt::Shift.closed.where(pending_orders_before: nil).update_all(pending_orders_before: 0)
    Ddt::Shift.closed.where(pending_orders_after: nil).update_all(pending_orders_after: 0)
    Ddt::Shift.closed.where(confirmed_orders_before: nil).update_all(confirmed_orders_before: 0)
    Ddt::Shift.closed.where(confirmed_orders_after: nil).update_all(confirmed_orders_after: 0)
    Ddt::Shift.closed.where(completed_orders_before: nil).update_all(completed_orders_before: 0)
    Ddt::Shift.closed.where(completed_orders_after: nil).update_all(completed_orders_after: 0)
  end
end
