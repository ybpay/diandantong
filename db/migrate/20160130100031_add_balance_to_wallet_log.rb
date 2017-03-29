class AddBalanceToWalletLog < ActiveRecord::Migration
  def change
    add_column :ddt_wallet_logs, :balance, :decimal, precision: 8, scale: 2
  end
end
