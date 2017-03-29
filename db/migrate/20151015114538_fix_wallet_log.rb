class FixWalletLog < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_wallet_logs l
      JOIN ddt_wallets w ON l.wallet_id = w.id
      SET l.cash_amount = l.amount
      where w.type in ('Ddt::UserCardWallet','Ddt::BranchCardWallet','Ddt::ShopCardWallet') and
            l.cash_amount = 0 and l.extra_amount = 0;
    SQL
  end

  def down

  end
end
