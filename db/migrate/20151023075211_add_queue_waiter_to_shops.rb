class AddQueueWaiterToShops < ActiveRecord::Migration
  def change
    Ddt::Shop.find_each{ |shop|
      shop.roles.create!(name: Ddt::Role::ROLE_SHOP_QUEUE_WAITER, builtin: true) if !shop.roles.queue_waiter_role.present?
    }
  end
end
