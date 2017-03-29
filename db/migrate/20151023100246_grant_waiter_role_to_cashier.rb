class GrantWaiterRoleToCashier < ActiveRecord::Migration
  def change
    progress = 0
    Ddt::Account.cashiers.find_each do |cashier|
      account = Ddt::Account.find(cashier.id)
      shop = account.shop
      waiter_role = shop.roles.waiter_role.first
      account.roles << waiter_role unless account.roles.include? waiter_role

      progress += 1
      puts "handle 1000 x #{progress} accounts" if progress % 1000 == 0
    end
  end
end
