class AddIndexToNotificationCache < ActiveRecord::Migration
  def change
  	add_index :ddt_app_notification_caches, [:account_id, :created_at], :name => "notification_cache_account_date"
  end
end
