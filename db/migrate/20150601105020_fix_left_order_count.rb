class FixLeftOrderCount < ActiveRecord::Migration
  def change
    # count = 0
    # Ddt::Branch.where(charge_method: :charge_by_orders_count).find_each do |branch|
    #   count += 1
    #   puts "fix left_orders_count branch#{branch.id}, #{count}" if count % 100 == 0
    #   left_count = branch.left_orders_count - branch.placed_orders_count
    #   branch.update_column(:left_orders_count, left_count < 0 ? 0: left_count)
    # end
  end
end
