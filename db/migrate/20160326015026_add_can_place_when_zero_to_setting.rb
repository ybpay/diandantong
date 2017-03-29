class AddCanPlaceWhenZeroToSetting < ActiveRecord::Migration
  def change
    add_column :ddt_eat_in_hall_settings, :can_place_when_zero, :boolean, default: false
    add_column :ddt_eat_in_hall_settings, :auto_pay_when_zero, :boolean, default: true
  end
end
