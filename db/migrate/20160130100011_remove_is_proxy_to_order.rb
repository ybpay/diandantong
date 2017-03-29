class RemoveIsProxyToOrder < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE ddt_orders o
      SET o.waiter_id = o.account_id
      where o.waiter_id is null and o.account_id is not null;
    SQL
    execute <<-SQL
      ALTER TABLE ddt_orders
        DROP is_proxy,
        DROP credits_total,
        DROP wallet_total,
        DROP account_id,
        DROP piece_code,
        DROP updated_piece_code_at,
        DROP is_webpos_printed;
    SQL
  end
end
