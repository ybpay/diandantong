class CreateSystemMessage < ActiveRecord::Migration
  def change
    drop_table :ddt_system_messages if table_exists? :ddt_system_messages
    create_table :ddt_system_messages do |t|
      t.references :shop, index: true
      t.references :account, index: true
      t.string :message_type
      t.text :content
      t.timestamps
    end

    unless column_exists? :ddt_notification_events, :system_message_id
      add_column :ddt_notification_events, :system_message_id, :integer
    end
    unless index_exists? :ddt_notification_events, :system_message_id
      add_index :ddt_notification_events, :system_message_id
    end
  end
end
