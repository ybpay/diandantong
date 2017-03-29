class ExtractAccountChanneId < ActiveRecord::Migration
  def change
    # delete "last_push_user_id"
    # delete "last_push_channel_id"
    remove_column :ddt_accounts, :last_push_user_id, :string
    remove_column :ddt_accounts, :last_push_channel_id, :string

    create_table :ddt_baidu_push_channels do |t|
      t.string :channel_id, unique: true
      t.string :user_id
      t.string :account_id
      t.string :os_type
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :ddt_baidu_push_channels, :channel_id
    add_index :ddt_baidu_push_channels, :account_id
    add_index :ddt_baidu_push_channels, :updated_at

    # add sample_at to locations
    add_column :ddt_locations, :sampled_at, :datetime
  end
end
