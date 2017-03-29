# encoding: utf-8
class MigrateLeftOrdersCount < ActiveRecord::Migration

  def change
    count = 0
    Ddt::Branch.where(charge_method: 'charge_by_orders_count').find_each do |branch|
      count += 1
      expiration_time = Ddt::Branch.change_orders_count_to_time(branch.left_orders_count)
      branch.update_columns(expiration_time: expiration_time)
      puts "migrate left orders count #{count}th, branch_id: #{branch.id}" if count % 100 == 0
    end
  end

end
