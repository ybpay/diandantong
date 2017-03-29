class FixPayItemNotActualAmount < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE ddt_pay_items SET not_actual_amount = amount * (100 - pay_method_percent_of_actual) / 100
      WHERE deleted_at IS NOT NULL
      AND state = 'paid'
      AND pay_method_name_sym != 'vip_card_pay'
      AND amount * (100 - pay_method_percent_of_actual) / 100 != not_actual_amount
    SQL

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
    SQL
  end
end
