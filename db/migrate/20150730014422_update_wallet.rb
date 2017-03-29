class UpdateWallet < ActiveRecord::Migration
  def up
    add_column :ddt_wallets, :cash_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_wallets, :extra_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_wallet_logs, :extra_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_wallets, :total_get_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_wallets, :total_used_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_deductions, :cash_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_deductions, :extra_amount, :decimal, precision: 8, scale: 2, default: 0.0
    execute "UPDATE ddt_deductions d SET d.cash_amount = d.amount;"
    execute "UPDATE ddt_wallets w SET w.cash_amount = w.amount;"
    execute "UPDATE ddt_wallet_logs w SET w.cash_amount = w.amount;"
  end

  def down
    remove_column :ddt_deductions, :extra_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_deductions, :cash_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_wallets, :total_used_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_wallets, :total_get_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_wallet_logs, :extra_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_wallets, :extra_amount, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_wallets, :cash_amount, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
