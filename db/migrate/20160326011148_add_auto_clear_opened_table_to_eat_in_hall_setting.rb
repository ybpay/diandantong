class AddAutoClearOpenedTableToEatInHallSetting < ActiveRecord::Migration
  def change
    add_column :ddt_eat_in_hall_settings, :auto_clear_opened_table, :boolean, default: false
  end
end
