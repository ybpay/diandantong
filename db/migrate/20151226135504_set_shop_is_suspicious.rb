class SetShopIsSuspicious < ActiveRecord::Migration
  def change
    puts "set account phone address"
    n = 0
    Ddt::Account.where(built_in: true).find_each do |account|
      phone_address = account.look_up_phone_address
      account.update_columns(phone_address: phone_address) if phone_address.present?
      n += 1
      puts "#{n}th account: #{account.id}" if n % 100 == 0
    end

    puts "set phone is_suspicious"
    suspicious_shop_ids = []
    n = 0
    Ddt::Shop.find_each do |shop|
      shop.set_is_suspicious(shop.creator.try(:phone_address))
      suspicious_shop_ids << shop.id if shop.is_suspicious?
      n += 1
      puts "#{n}th, shop: #{shop.id}" if n%100 == 0
    end
    Ddt::Shop.where(id: suspicious_shop_ids).update_all(is_suspicious: true)
  end
end
