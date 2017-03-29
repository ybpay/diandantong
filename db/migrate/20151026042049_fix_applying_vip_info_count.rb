class FixApplyingVipInfoCount < ActiveRecord::Migration
  def change
    count = 0
    Ddt::Shop.find_each do |shop|
      count += 1
      applying_count = Ddt::VipInfo.applying.where(shop_id: shop.id).count
      shop.update_column(:applying_vip_info_count, applying_count)
      puts "migrate #{count}th shop, ID: #{shop.id}" if count % 100 == 0
    end
  end
end
