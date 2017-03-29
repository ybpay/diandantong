class FixShopInitializer < ActiveRecord::Migration
  def change
    shop_ids = (execute "SELECT s.id  FROM ddt_shops as s LEFT JOIN ddt_vip_levels as l on s.id = l.shop_id WHERE l.id is null").to_a.flatten
    count = shop_ids.count
    methods = [:create_default_vip_level!, :create_email_setting!, :create_short_message_setting!, :create_call_setting!, :create_credits_setting!, :create_card_key!, :create_competition_resource!, :create_default_pay_method!]
    Ddt::Shop.where(id: shop_ids).each_with_index do |shop, index|
      puts "==> #{index}/#{count}, ID: #{shop.id}, SLUG: #{shop.slug}, Tel: #{shop.phone}"
      init = Ddt::ShopInitializer.new(shop)
      methods.each do |method|
        init.send method
      end
    end
  end
end
