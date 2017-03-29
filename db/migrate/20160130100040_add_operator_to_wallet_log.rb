class AddOperatorToWalletLog < ActiveRecord::Migration
  def change
    add_column :ddt_wallet_logs, :operator_type, :string unless column_exists? :ddt_wallet_logs, :operator_type
    add_column :ddt_wallet_logs, :operator_id, :integer unless column_exists? :ddt_wallet_logs, :operator_id
    add_column :ddt_wallet_logs, :operator_name, :string unless column_exists? :ddt_wallet_logs, :operator_name
  end
end
