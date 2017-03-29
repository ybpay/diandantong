class AddSupportOrderTypeToPayMethod < ActiveRecord::Migration
  def change
    add_column :ddt_pay_methods, :support_delivery, :boolean, default: true
    add_column :ddt_pay_methods, :support_eat_in_hall, :boolean, default: true
    add_column :ddt_pay_methods, :support_fastfood, :boolean, default: true
    add_column :ddt_pay_methods, :support_reservation, :boolean, default: true
    add_column :ddt_pay_methods, :support_groupon, :boolean, default: true
    add_column :ddt_pay_methods, :support_recharge, :boolean, default: true
    add_column :ddt_pay_methods, :support_payment, :boolean, default: true
  end
end
