class AddPayMethodToWalletLog < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_wallet_logs, :pay_method_id
      add_column :ddt_wallet_logs, :pay_method_id, :integer
      add_column :ddt_wallet_logs, :pay_method_name, :string
    end
  end
end
