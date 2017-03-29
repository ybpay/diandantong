class FixDirtyPayItem < ActiveRecord::Migration
  def change
    add_column :ddt_pay_items, :deleted_at, :datetime unless column_exists? :ddt_pay_items, :deleted_at
    pay_items = Ddt::PayItem.includes(:order).where("ddt_orders.paid_at is not null and ddt_pay_items.paid_at is null").references(:ddt_orders)
    puts "totally find #{pay_items.count} pay items which have invalid pay_items"
    pay_items.find_each do |pay_item|
      pay_item.update_columns(state: :paid, paid_at: pay_item.order.paid_at)
    end
  end

end
