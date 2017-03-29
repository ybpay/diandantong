class AddCashAmountToWallet < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_wallet_logs, :cash_amount
      add_column :ddt_wallet_logs, :cash_amount, :decimal, precision: 8, scale: 2, default: 0.0
    end
  end
end
