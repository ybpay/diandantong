class AddDefaultPayPassword < ActiveRecord::Migration
  def change
    index = 0
    Ddt::VipInfo.find_each do |vip_info|
      if index % 100 == 0
        puts "start to create default password for vip_info #{vip_info.id} "
      end
      index += 1
      vip_info.send(:create_default_password)
    end
  end
end
