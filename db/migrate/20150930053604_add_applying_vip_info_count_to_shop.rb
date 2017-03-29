class AddApplyingVipInfoCountToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :applying_vip_info_count, :integer, default: 0

    c = 0
    Ddt::Shop.find_each do |shop|
      c += 1
      puts "migrate applying_vip_info_count #{c}th #{shop.id}" if c%100==0
      n = Ddt::BaseUser.where(:shop_id => shop.id).of_apply_vip_users.count
      if n!=0
        shop.update_columns(applying_vip_info_count: n)
      end
    end
  end
end
