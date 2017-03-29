class AddUserIdToNotificationEvent < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_notification_events, :user_id
      add_column :ddt_notification_events, :user_id, :integer, index: true
    end
  end
end
