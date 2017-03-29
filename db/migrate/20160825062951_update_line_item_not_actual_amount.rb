class UpdateLineItemNotActualAmount < ActiveRecord::Migration
  def change
    order_ids = Ddt::LineItem.where(branch_id: 8731).where('not_actual_amount < 0').pluck(:order_id)
    Ddt::OrderService::Order::Base.where(id: order_ids) do |order|
      order.update_line_item_not_actual_amount
      order.save
      order.line_items.select{|line_item| line_item.is_combo_package?}.each do |line_item|
        set_adjustments(line_item)
      end
    end
  end

  def set_adjustments(line_item)
    @fixed_ids ||= []
    return if @fixed_ids.include?(line_item.id)
    Ddt::ComboPackageItem.set_adjustments(line_item)
    @fixed_ids << line_item.id
  end

end
