class FixAdjustments < ActiveRecord::Migration
  def change
    fix_anti_settlement
    fix_credit_reduction
    #puts "total fix: #{@fixed_ids.count}"
  end

  def fix_anti_settlement
    order_ids = Ddt::OrderChangeLog.where(type: 'Ddt::OrderChangeLog::AntiSettlement').pluck(:order_id).uniq
    if order_ids.present?
      count = order_ids.count
      puts "============== order_ids count: #{count} ==========================================="
      order_ids.each_with_index do |order_id, index|
        puts "============= #{order_id} === #{index}/#{count} ========"
        fix_adjustments(order_id)
      end
    end
  end

  def fix_credit_reduction
    order_ids = Ddt::CreditsDeduction.where(state: 'completed').pluck(:order_id).uniq
    if order_ids.present?
      count = order_ids.count
      puts "************** Credit reduction: #{count} ********************************************"
      order_ids.each_with_index do |order_id, index|
        puts "============= #{order_id} === #{index}/#{count} ========"
        fix_adjustments(order_id)
      end
    end
  end

  def fix_adjustments(order_id)
    @fixed_ids ||= []
    return if @fixed_ids.include?(order_id)
    order = Ddt::OrderService::Order::Base.find(order_id) rescue nil
    if order.present? && order.paid?
      order.update_line_item_not_actual_amount
      order.update_combo_package_item_adjustments
      order.save
      @fixed_ids << order_id
    end
  end
end