class RemoveCartData < ActiveRecord::Migration
  def up
    execute("delete l from ddt_line_items        as l join ddt_orders as o on o.id = l.order_id where o.state = 'cart';")
    execute("delete l from ddt_adjustments       as l join ddt_orders as o on o.id = l.order_id where o.state = 'cart';")
    execute("delete l from ddt_pay_items         as l join ddt_orders as o on o.id = l.order_id where o.state = 'cart';")
    execute("delete l from ddt_form_contents     as l join ddt_orders as o on o.id = l.order_id where o.state = 'cart';")
    execute("delete l from ddt_promotions_orders as l join ddt_orders as o on o.id = l.order_id where o.state = 'cart';")
    # execute("delete from ddt_orders where placed_at is null;")
  end

  def down
  end
end
