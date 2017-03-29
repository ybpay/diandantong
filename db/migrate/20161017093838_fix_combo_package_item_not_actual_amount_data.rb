class FixComboPackageItemNotActualAmountData < ActiveRecord::Migration
  def change
    sql = <<-SQL
      select l.order_id, l.id, l.not_actual_amount, cpi.combo_package_id, sum(cpi.not_actual_amount) as cpi_not_actual_amount from ddt_line_items as l
      inner join ddt_combo_package_items as cpi on l.itemable_id = cpi.combo_package_id
      where l.deleted_at is null
        and l.created_at >= '2016-01-01 00:00:00'
        and l.created_at < '2016-11-16 23:59:59'
        and l.is_subtract = 0
        and l.gift = 0
        and l.is_moved = 0
        and l.itemable_type = 'Ddt::ComboPackage'
        and (l.quantity - l.subtract_quantity - l.move_quantity) > 0
        and l.not_actual_amount != 0
        group by cpi.combo_package_id having not_actual_amount != cpi_not_actual_amount;
    SQL
    r = execute sql
    r = r.to_a
    r.each do |row|
      order = Ddt::OrderService::Order::Base.includes(:line_items, :pay_items).find(row[0])
      line_item = order.line_items.find(row[1])
      Ddt::ComboPackageItem.set_adjustments(line_item)
    end
  end
end
