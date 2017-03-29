class CreateDefaultValuesForSyncSubscribe < ActiveRecord::Migration
  def up
    Ddt::GuestQueue.where('guest_num is null').update_all(:guest_num => 0)
    Ddt::Shift.where('pre_cash_amount is null').update_all(:pre_cash_amount => 0)
    Ddt::Table.where('guest_num is null').update_all(:guest_num => 0)

    change_column :ddt_guest_queues, :guest_num, :integer, default: 0, :null => false
    change_column :ddt_shifts, :pre_cash_amount, :integer, default: 0, :null => false
    change_column :ddt_tables, :guest_num, :integer, default: 0, :null => false
  end

  def down

  end
end
