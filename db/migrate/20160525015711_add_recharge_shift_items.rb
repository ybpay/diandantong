class AddRechargeShiftItems < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shift_items, :item_type
      add_column :ddt_shift_items, :item_type, :string, default: "base"
    end
    Ddt::ShiftItem.all.update_all(item_type: "base")
    unless column_exists? :ddt_shifts, :recharge_extra_amount
      add_column :ddt_shifts, :recharge_extra_amount, :decimal, precision: 8, scale: 2, default: 0
    end
    unless column_exists? :ddt_shifts, :vip_card_pay_amount
      add_column :ddt_shifts, :vip_card_pay_amount, :decimal, precision: 8, scale: 2, default: 0
    end
    unless column_exists? :ddt_shifts, :recharge_order_count
      add_column :ddt_shifts, :recharge_order_count, :integer, default: 0
    end
  end
end
