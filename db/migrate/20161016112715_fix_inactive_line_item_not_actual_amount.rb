class FixInactiveLineItemNotActualAmount < ActiveRecord::Migration
  def change
    r = execute <<-SQL
      SELECT order_id FROM ddt_line_items
      WHERE deleted_at IS NULL
      AND quantity - subtract_quantity - move_quantity < 1
      AND not_actual_amount != 0
    SQL
    order_ids = r.to_a.flatten
    count = order_ids.count
    order_ids.each_slice(200).to_a.each_with_index do |oids, index|
      puts "==============#{index+1}th 200 orders/#{count}"
      Ddt::OrderService::Order::Base.includes(:line_items, :pay_items).find(oids).each do |order|
        order.update_line_item_not_actual_amount
        order.save
        order.line_items.select{|line_item| line_item.is_combo_package?}.each do |line_item|
          Ddt::ComboPackageItem.set_adjustments(line_item)
        end
      end
    end
  end

end
