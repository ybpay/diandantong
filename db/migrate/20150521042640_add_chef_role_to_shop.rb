class AddChefRoleToShop < ActiveRecord::Migration
  def change
    chef_hash = {name: Ddt::Role::ROLE_SHOP_CHEF, builtin: true}
    count = 0
    Ddt::Shop.all.find_each do |shop|
      if shop.roles.find_by(chef_hash).blank?
        count += 1
        puts "Add chef role to shop(#{shop.id}) #{count}" if count % 100 == 0
        shop.roles.create! chef_hash
      end
    end
  end
end
