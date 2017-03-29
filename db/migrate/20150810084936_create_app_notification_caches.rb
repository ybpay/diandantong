class CreateAppNotificationCaches < ActiveRecord::Migration
  def change
    create_table :ddt_app_notification_caches do |t|
      t.integer :account_id
      t.integer :notification_id
      t.integer :notification_event_id
      t.integer :notification_action_id
      t.text :message
      t.timestamps
    end

    add_index :ddt_app_notification_caches, :account_id, name: :anc_account
    add_index :ddt_app_notification_caches, :notification_id, name: :anc_notification
    add_index :ddt_app_notification_caches, :notification_action_id, name: :anc_action
    add_index :ddt_app_notification_caches, :notification_event_id, name: :anc_event
    add_index :ddt_app_notification_caches, :created_at, name: :anc_created_at
  end
end
