class CreateDdtPushChannels < ActiveRecord::Migration
  def up
    create_table :ddt_push_channels do |t|
      t.string :j_push_channel_id,  index: true
      t.integer :account_id, index: true
      t.string :os_type
      t.date :expired_at

      t.timestamps
    end unless table_exists? :ddt_push_channels
  end

  def down
    if table_exists? :ddt_push_channels
        drop_table :ddt_push_channels
    end
  end
end
