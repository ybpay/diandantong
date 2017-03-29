class AddPaymentOrder < ActiveRecord::Migration
  def up
    Ddt::Order.where(type: 'Ddt::EatInHallOrder', item_count: 0).where.not(state: :merged).update_all(type: "Ddt::PaymentOrder")
  end

  def down
    Ddt::Order.where(type: 'Ddt::PaymentOrder').update_all(type: "Ddt::EatInHallOrder")
  end
end
