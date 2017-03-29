class ChangeDisableService < ActiveRecord::Migration
  def change
    rename_column :ddt_eat_in_hall_settings, :disable_call_waiter, :disable_service
  end
end
