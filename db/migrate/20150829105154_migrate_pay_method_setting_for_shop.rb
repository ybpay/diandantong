class MigratePayMethodSettingForShop < ActiveRecord::Migration
  def change
    count = 0
    Ddt::Shop.find_each do |shop|
      puts "migrate paymethod setting for shop #{count}th shop_id: #{shop.id}" if count % 100 == 0
      shop.create_fastfood_pay_method_setting!
      count+=1
    end
  end
end
