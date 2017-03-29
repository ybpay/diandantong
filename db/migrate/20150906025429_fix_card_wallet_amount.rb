class FixCardWalletAmount < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_wallets w
      SET w.extra_amount = w.amount - w.cash_amount
      WHERE w.deleted_at IS NULL
        AND w.type = 'Ddt::UserCardWallet'
        AND ABS(w.amount - (w.cash_amount + w.extra_amount)) > 0
        AND ABS(w.amount - (w.cash_amount + w.extra_amount)) < 0.05;
    SQL
  end

  def down
  end
end
