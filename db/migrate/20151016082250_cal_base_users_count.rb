class CalBaseUsersCount < ActiveRecord::Migration
  def change
    n = 0
    Ddt::VipInfo.find_each do |vip_info|
      n += 1
      Ddt::VipInfo.reset_counters vip_info.id, :base_users
      puts "#{n}th vipinfo reset counter success" if n % 100 == 0
    end
  end
end
