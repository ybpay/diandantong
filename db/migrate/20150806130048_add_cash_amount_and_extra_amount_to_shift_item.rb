class AddCashAmountAndExtraAmountToShiftItem < ActiveRecord::Migration
  def change
    add_column :ddt_shift_items, :cash_amount, :decimal, precision: 8, scale: 2 unless column_exists? :ddt_shift_items, :cash_amount
    add_column :ddt_shift_items, :extra_amount, :decimal, precision: 8, scale: 2 unless column_exists? :ddt_shift_items, :extra_amount
    index = 0
    total_index = Ddt::Shift.closed.count
    Ddt::Shift.closed.find_each do |shift|
      puts "start to migrate for shift #{shift.id} of branch #{shift.branch_id}"
      pay_method = shift.shop.pay_methods.where(name_sym: :vip_card_pay).first
      item = shift.shift_items.where(pay_method: pay_method).first
      branch = Ddt::Branch.with_deleted.find(shift.branch_id)
      if item.present?
        item.cash_amount = branch.card_wallet.wallet_logs.where(reason: :for_vip_card_pay, created_at: shift.created_at..shift.closed_at).sum(:cash_amount)
        item.extra_amount = branch.card_wallet.wallet_logs.where(reason: :for_vip_card_pay, created_at: shift.created_at..shift.closed_at).sum(:extra_amount)
        item.save(validate: false)
      end
      puts "update shift amount : #{index}/#{total_index}" if index % 100 == 0
      index += 1
    end
  end
end
