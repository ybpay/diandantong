class AddNotActualAmountToPayItem < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_pay_items, :not_actual_amount
      add_column :ddt_pay_items, :not_actual_amount, :decimal, scale: 2, precision: 10, default: 0.0
    end
    sql = "update ddt_pay_items set not_actual_amount=amount*(100-pay_method_percent_of_actual)/100 where state='paid' and pay_method_name_sym!='vip_card_pay';"
    execute sql
    sql = <<-SQL.strip_heredoc
      UPDATE ddt_pay_items AS p 
      INNER JOIN ddt_wallet_logs AS l ON p.order_id = l.order_id
      INNER JOIN ddt_wallets AS w ON w.id = l.wallet_id
      SET p.not_actual_amount = l.extra_amount
      WHERE 
        p.state = 'paid'
        AND p.deleted_at IS NULL
        AND w.owner_type = 'Ddt::Branch'
        AND l.reason = 'for_vip_card_pay';
    SQL
    execute sql
  end
end
