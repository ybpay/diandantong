class FixAppendPayItemData < ActiveRecord::Migration
  def change
    Ddt::PayItem.where(is_append: true).find_each do |pay_item|
      order = Ddt::Order.find_by(id: pay_item.order_id)
      if order.present? && order.type == 'Ddt::RechargeOrder' && ['completed', 'paid'].include?(order.state)
        fix_shift(order, pay_item)
      end
    end
  end

  def fix_shift(order, pay_item)
    shift = ::Ddt::Shift.where("branch_id = :branch_id and created_at < :paid_at and closed_at > :paid_at", { branch_id: order.branch_id, paid_at: order.paid_at }).first
    if shift.present?
      base_shift_item = shift.shift_items.where(pay_method_id: pay_item.pay_method_id, item_type: :base).first
      recharge_shift_item = shift.shift_items.where(pay_method_id: pay_item.pay_method_id, item_type: :recharge).first
      if base_shift_item.present? && recharge_shift_item.present?
        actual_amount = pay_item.amount * pay_item.pay_method_percent_of_actual

        #Fix Base shift_item
        base_shift_item.amount -= pay_item.amount
        base_shift_item.actual_amount -= actual_amount
        base_shift_item.save!

        #Fix Recharge shift_item
        recharge_shift_item.amount += pay_item.amount
        recharge_shift_item.actual_amount += actual_amount
        recharge_shift_item.save!

        puts "Fixed: #{pay_item.id}"

      else
        puts "StateInvalid: shift #{shift.id} pay_item #{pay_item.id}"
      end
    end
  end


end
