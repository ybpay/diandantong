#encoding: utf-8
class AddVipInfoManagerRole < ActiveRecord::Migration
  def change
    Ddt::Shop.find_each do |shop|
      # 增加会员管理内建角色
      new_role = shop.roles.create!(name: Ddt::Role::ROLE_SHOP_VIP_INFO_MANAGER, builtin: true)
      # 收银员自动获取该角色
      shop.accounts.cashiers.find_each do |account|
        account.roles << new_role
      end
    end

  end
end
