class AddAccountantToShops < ActiveRecord::Migration
  def change
  	Ddt::Shop.find_each{ |shop|
      shop.roles.create!(name: Ddt::Role::ROLE_SHOP_ACCOUNTANT, builtin: true) if !shop.roles.accountant_role.present?
    }
  end
end
