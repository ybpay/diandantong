class FixShiftRollbackLog < ActiveRecord::Migration
  def up
    Ddt::WalletLog.where(reason: :for_rollback_vip_card_pay).where("created_at > '2016-01-01 00:00'").find_each do |log|
      puts "============ wallet_log: #{log.id} ============"
      pre_log = Ddt::WalletLog.where(reason: :for_vip_card_pay, order_id: log.order_id, wallet_id: log.wallet_id).where("created_at < ?", log.created_at).first
      if pre_log.present? && log.amount == -pre_log.amount
        diff_amount = log.cash_amount + pre_log.cash_amount
        log.update(cash_amount: -pre_log.cash_amount, extra_amount: -pre_log.extra_amount)
        if log.wallet.owner.is_a?(Ddt::Branch)
          branch = log.wallet.owner
          pay_method_id = branch.shop.pay_methods.where(name_sym: "vip_card_pay").first.id
          shift = branch.shifts.where("created_at < ? and closed_at > ?", log.created_at, log.created_at).closed.first
          if shift.present?
            shift_item = shift.base_shift_items.where(pay_method_id: pay_method_id).first
            if shift_item.present?
              shift_item.cash_amount -= diff_amount
              shift_item.extra_amount += diff_amount
              shift_item.actual_amount -= diff_amount
              shift_item.save
            end
          end
        end
      else
        puts "=============== error_log: #{log.id} =============="
      end
    end
  end

  def down
  end
end
