class FixMissingVipInfo < ActiveRecord::Migration
  def change
  	index = 0 
    Ddt::BaseUser.joins(:vip_info).where('ddt_vip_infos.id is NULL or ddt_vip_infos.deleted_at is NOT NULL').find_each do |u|
      # 保证 vip_info 的存在
      if index % 100 == 0
      	puts "start to migrate the #{index}th record of id #{u.id}"
      end
      index ++ 
      unless u.vip_info.present?
        begin
          u.send(:create_default_vip_info)
        rescue => e
          puts "Migrate Error of #{u.id}: #{e}"
        end
      end
      
    end
  end
end
