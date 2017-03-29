class FixPayItemData < ActiveRecord::Migration
  def up
    Ddt::PayItem.joins(:order).where(
      ddt_orders: {
        state: :completed,
        multi_pay_item: false,
        pay_method: [:pay_on_face, :pay_on_receive, :pay_on_arrive]
      }).update_all(state: :paid)
  end

  def down
  end
end
