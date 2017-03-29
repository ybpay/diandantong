class FixLineItemItemableName < ActiveRecord::Migration
  def change
    n = 0
    Ddt::LineItem.where(itemable_name: nil).find_each do |line_item|
      line_item.update_column(:itemable_name, line_item.itemable.itemable_name)
      n += 1
      puts "#{n}th, line_item: #{line_item.id}" if n%100 == 0
    end
  end
end
