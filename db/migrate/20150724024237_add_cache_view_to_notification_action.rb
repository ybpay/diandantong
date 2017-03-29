class AddCacheViewToNotificationAction < ActiveRecord::Migration
  def change
    add_column :ddt_notification_actions, :cache_view, :text
  end
end
