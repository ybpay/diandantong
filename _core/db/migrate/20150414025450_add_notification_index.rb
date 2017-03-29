class AddNotificationIndex < ActiveRecord::Migration
  def change
  	change_column :ddt_notification_actions, :type, :string, limit: 100
  	change_column :ddt_notification_events, :type, :string, limit: 100
    add_index :ddt_notification_actions, [:type, :id]
    remove_index :ddt_notification_events, [:id, :type]
    add_index :ddt_notification_events, [:type, :id]
    add_index :ddt_notification_events, [:updated_at]
  end
end
