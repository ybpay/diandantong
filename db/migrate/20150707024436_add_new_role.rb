class AddNewRole < ActiveRecord::Migration
  def change
    index = 0
    Ddt::Shop.all.find_each do |shop|
      shop.roles.create!(name: Ddt::Role::ROLE_SHOP_WAITER, builtin: true)
      shop.roles.create!(name: Ddt::Role::ROLE_SHOP_CASHIER, builtin: true)
      index += 1
      puts "index = #{index}" if index % 100 == 0
    end
  end
end
