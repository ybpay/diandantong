class AddModeToEatInHallSetting < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_eat_in_hall_settings, :mode
      add_column :ddt_eat_in_hall_settings, :mode, :string, default: :pay_after
    end
  end
end
