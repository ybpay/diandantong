class AddWalletLogIdToNotificationEvent < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_notification_events, :wallet_log_id
      add_column :ddt_notification_events, :wallet_log_id, :integer
      add_index :ddt_notification_events, :wallet_log_id
    end
  end
end
