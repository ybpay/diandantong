class FixOldVipInfo < ActiveRecord::Migration
  def change
    phone_users = []
    dirty_data = []
    n = 0
    Ddt::VipInfo.where(builtin: false).find_each do |v|
      phone_user = Ddt::PhoneUser.where("phone = ? or vip_info_id = ?", v.phone, v.id)
      if phone_user.blank?
        phone_users << Ddt::PhoneUser.new(vip_info_id: v.id, shop_id: v.shop_id, name: v.name, phone: v.phone)
      else
        phone_user.each do |u|
          if u.vip_info_id != v.id
            dirty_data << [v.id, u.id]
          end
        end
      end
      n += 1
      puts "#{n}th, vip_info: #{v.id}" if n%100 == 0
    end
    puts "dirty vip_info: #{phone_users.size}"
    Ddt::PhoneUser.import(phone_users)
    puts "dirty data: #{dirty_data.size}"
  end
end
