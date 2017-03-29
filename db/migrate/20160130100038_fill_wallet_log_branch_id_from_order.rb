class FillWalletLogBranchIdFromOrder < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE ddt_wallet_logs AS l
      LEFT JOIN ddt_orders AS o ON l.order_id = o.id
      SET l.branch_id = o.branch_id
      WHERE l.order_id IS NOT NULL
    SQL
  end
end
