class AddDisableCallWaiterToEatInHallSettings < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_eat_in_hall_settings, :disable_call_waiter
      add_column :ddt_eat_in_hall_settings, :disable_call_waiter, :boolean, default: false
    end
  end
end
