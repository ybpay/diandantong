class CreateSystemMessage < ActiveRecord::Migration
  def connection
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def with_proper_connection
    @connection = ActiveRecord::Base.octopus_establish_connection "impression_#{Rails.env}".to_sym
    yield
    @connection ||= ActiveRecord::Base.octopus_establish_connection "#{Rails.env}".to_sym
  end

  def change
    with_proper_connection do
      ActiveRecord::Migration.drop_table :ddt_system_messages if ActiveRecord::Migration.table_exists? :ddt_system_messages
      ActiveRecord::Migration.create_table :ddt_system_messages do |t|
        t.references :shop, index: true
        t.references :account, index: true
        t.string :message_type
        t.text :content
        t.timestamps
      end

      unless ActiveRecord::Migration.column_exists? :ddt_notification_events, :system_message_id
        ActiveRecord::Migration.add_column :ddt_notification_events, :system_message_id, :integer
      end
      unless ActiveRecord::Migration.index_exists? :ddt_notification_events, :system_message_id
        ActiveRecord::Migration.add_index :ddt_notification_events, :system_message_id
      end
    end
  end
end
