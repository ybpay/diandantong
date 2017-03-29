#encoding: utf-8
class AddAntiSettlementToOrder < ActiveRecord::Migration
  def change
    add_column :ddt_pay_items, :deleted_at, :datetime unless column_exists? :ddt_pay_items, :deleted_at
    add_column :ddt_orders, :anti_settlement, :boolean, default: false unless column_exists? :ddt_orders, :anti_settlement

    # 所有取消了的，且支付状态为 paid, :partial_paid 的都是反结账订单
    ActiveRecord::Base.transaction do
      order_numbers = []
      Ddt::Order
        .where(state: :canceled)
        .where("(pay_item_state = 'paid' or pay_item_state = 'partial_paid')")
          .find_each do |order|
        # 使用 update_column 防止级联反应
        order.update_columns(
                 anti_settlement: true,
                 pay_item_state: :none,
        )
        # 软删除所有支付项
        order.pay_items.destroy_all

        order_numbers << order.try(:number)
        if order_numbers.length % 100 == 0
          puts "migrate 100 orders: #{order_numbers.join(' ')}"
          order_numbers.clear
        end
      end
    end
  end
end
