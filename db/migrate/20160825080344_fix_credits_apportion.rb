class FixCreditsApportion < ActiveRecord::Migration
  def up
    sql = <<-SQL
      select o.id
      from ddt_orders o
      inner join ddt_adjustments as a on a.order_id = o.id
      where
        o.delete_by_admin = 0 and
        o.placed_at > '2016-01-01 00:00' and
        o.pay_item_state = 'paid' and
        a.reason = 'credits_deduction' and
        a.deleted_at is NULL and
        a.parent_id is NULL and 
        o.item_total < -a.amount;
    SQL
    order_ids = execute(sql).to_a.flatten
    count = order_ids.count
    puts "============== order_ids count: #{count} =============="
    order_ids.each_with_index do |order_id, index|
      order = Ddt::OrderService::Order::Base.find(order_id)
      puts "============= #{order_id} shop_id:#{order.shop_id}=== #{index}/#{count} ========"
      adjustment = order.adjustments.credits_deduction.first
      over_amount = order.item_total + order.adjustment_total
      if adjustment.item_adjustments.present?
        order.adjustment_total -= over_amount
        adjustment.item_adjustments.each do |item_adjustment|
          sub_over_amount = (over_amount * (item_adjustment.amount / adjustment.amount )).round_to_floor(2)
          item_adjustment.amount -= sub_over_amount
        end
        adjustment.amount -= over_amount
        diff_amount = (adjustment.amount - adjustment.item_adjustments.map(&:amount).sum).round_to_floor(2)
        adjustment.item_adjustments.first.amount += diff_amount
        order.update_line_item_adjustment_total
        order.save
      else
        adjustment.amount -= over_amount
        amount = adjustment.amount
        items = order.line_items.active.select(&:enable_discount?)
        item_subtotal_sum = items.map(&:subtotal).sum
        if item_subtotal_sum > 0
          item_adjustments = items.map do |item|
            item_adjustment_amount = (amount * (1.0 * item.subtotal / item_subtotal_sum)).round_to_floor(2)
            item.get_item_adjustment(item_adjustment_amount, is_apportion: true)
          end
          rounding_diff_amount = (amount - item_adjustments.map(&:amount).sum).round(2)
          item_adjustments.first.amount += rounding_diff_amount if rounding_diff_amount != 0 && item_adjustments.present?
          adjustment.init_item_adjustments(item_adjustments)
          order.update_line_item_adjustment_total
          order.save
        end
      end
    end
  end

  def down
  end
end
