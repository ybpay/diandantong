class FixVipCardPayItemNotActualAmount < ActiveRecord::Migration
  def change
    fix_pay_item_not_actual_amount
    update_line_item_not_actual_amount
  end

  def update_line_item_not_actual_amount
    r = execute <<-SQL
      select order_id, count(*) as c
      from ddt_pay_items
      where deleted_at is null and pay_method_name_sym = 'vip_card_pay' and state = 'paid' group by order_id having c > 1;
    SQL
    order_ids = r.to_a.map{|row| row[0]}
    if order_ids.present?
      count = order_ids.count
      puts "=========> Total: #{count}========================================"
      order_ids.each_slice(200).each_with_index do |oids, index|
        puts "==#{index}==#{oids.size}/#{count}====="
        Ddt::OrderService::Order::Base.includes(:line_items, :pay_items).find(oids).each do |order|
          order.update_line_item_not_actual_amount
          order.update_combo_package_item_adjustments
          order.save
        end
      end
    end
  end

  def fix_pay_item_not_actual_amount
    execute <<-SQL
      UPDATE ddt_pay_items AS p
      INNER JOIN ddt_wallet_logs AS l ON p.order_id = l.order_id
      INNER JOIN ddt_wallets AS w ON w.id = l.wallet_id
      SET p.not_actual_amount = l.extra_amount
      WHERE
        p.state = 'paid'
        AND p.deleted_at IS NULL
        AND w.owner_type = 'Ddt::Branch'
        AND l.reason = 'for_vip_card_pay'
        and p.amount = l.amount
    SQL
  end
end
