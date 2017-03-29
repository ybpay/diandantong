class FixAppendPayItemData2 < ActiveRecord::Migration
  def change
    Ddt::PayItem.where(is_append: true).find_each do |pay_item|
      order = Ddt::Order.find_by(id: pay_item.order_id)
      if order.present? && order.type == 'Ddt::RechargeOrder' && ['completed', 'paid'].include?(order.state)
        fix_shift(order, pay_item)
      end
    end
  end

  def fix_shift(order, pay_item)
    @fixed_shift_ids ||= []


    shift = Ddt::Shift.where("branch_id = :branch_id and created_at < :paid_at and closed_at > :paid_at", { branch_id: order.branch_id, paid_at: order.paid_at }).first
    if shift.present? && @fixed_shift_ids.exclude?(shift.id)
      class << shift
        def current_shard
          :master
        end
      end
      shift.update_amount
      @fixed_shift_ids << shift.id
      puts "FixShift: #{shift.id}"
    end
  end
end
