class AddDeliveryManIdToDdtOrders < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_orders, :delivery_man_id
      add_column :ddt_orders, :delivery_man_id, :integer
    end
    execute <<-SQL
      UPDATE ddt_orders as o
      inner join ddt_shipments as s
      on o.id = s.order_id
      set o.delivery_man_id = s.delivery_man_id
      where s.delivery_man_id IS NOT NULL
      and o.type = "Ddt::DeliveryOrder"
    SQL
  end
end


