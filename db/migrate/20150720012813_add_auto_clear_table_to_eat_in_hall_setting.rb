class AddAutoClearTableToEatInHallSetting < ActiveRecord::Migration
  def change
    add_column :ddt_eat_in_hall_settings, :auto_clear_table, :boolean, default: true
    transaction do
      index = 0
      Ddt::Branch.all.includes(:eat_in_hall_setting).find_each do |branch|
        branch.create_eat_in_hall_setting! if branch.eat_in_hall_setting.blank?
        puts "branch index #{index}" if index % 100 == 0
        index += 1
      end
    end
  end
end
