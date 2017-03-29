class FixWalletLogAmountPrecision < ActiveRecord::Migration
  def change
    change_column :ddt_wallet_logs, :amount, :decimal, precision: 12, scale: 2
  end
end
