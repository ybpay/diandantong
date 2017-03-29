class FixShiftOrderInfos < ActiveRecord::Migration
  def change

    # add_column :ddt_shifts, :pending_orders_before, :integer, default: 0
    # add_column :ddt_shifts, :pending_orders_after, :integer, default: 0
    #
    # add_column :ddt_shifts, :confirmed_orders_before, :integer, default: 0
    # add_column :ddt_shifts, :confirmed_orders_after, :integer, default: 0
    #
    # add_column :ddt_shifts, :completed_orders_before, :integer, default: 0
    # add_column :ddt_shifts, :completed_orders_after, :integer, default: 0

    Ddt::Shift.find_each do |shift|
      branch = Ddt::Branch.with_deleted.find(shift.branch_id)
      shift.pending_orders_before = branch.orders.where('placed_at < ? and (confirmed_at = null or confirmed_at > ?)', shift.created_at, shift.created_at).count
      shift.confirmed_orders_before = branch.orders.where('confirmed_at < ? and (completed_at = null or completed_at > ?)', shift.created_at, shift.created_at).count
      shift.completed_orders_before = branch.orders.where('completed_at < ?', shift.created_at).count

      if (shift.state == 'closed')
        shift.pending_orders_after = branch.orders.where('placed_at < ? and (confirmed_at = null or confirmed_at > ?)', shift.closed_at, shift.closed_at).count
        shift.confirmed_orders_after = branch.orders.where('confirmed_at < ? and (completed_at = null or completed_at > ?)', shift.closed_at, shift.closed_at).count
        shift.completed_orders_after = branch.orders.where('completed_at < ?', shift.closed_at).count
      end
    end

  end
end
