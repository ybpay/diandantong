class MigrateFastfoodOrder < ActiveRecord::Migration
  def change
    Ddt::Order.where(type: 'Ddt::EatInHallOrder', table_id: nil).update_all(type: 'Ddt::FastfoodOrder')
  end
end
