class AddActualAmountToShiftItem < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shift_items, :actual_amount
      add_column :ddt_shift_items, :actual_amount, :decimal, precision: 8, scale: 2, default: 0.0
    end
    # no vip_card_pay
    Ddt::ShiftItem.where('pay_method_is_actual=1 AND cash_amount IS NULL').update_all('actual_amount = amount')
    # vip_card_pay
    Ddt::ShiftItem.where('pay_method_is_actual=1 AND cash_amount IS NOT NULL').update_all('actual_amount=cash_amount')

  end
end
