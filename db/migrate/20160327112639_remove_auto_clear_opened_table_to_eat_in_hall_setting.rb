class RemoveAutoClearOpenedTableToEatInHallSetting < ActiveRecord::Migration
  def change
    remove_column :ddt_eat_in_hall_settings, :auto_clear_opened_table
  end
end
