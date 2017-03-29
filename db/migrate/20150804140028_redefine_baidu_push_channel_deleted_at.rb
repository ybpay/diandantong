class RedefineBaiduPushChannelDeletedAt < ActiveRecord::Migration
  def change
    rename_column :ddt_baidu_push_channels, :deleted_at, :expired_at
    add_index :ddt_baidu_push_channels, :expired_at
  end
end
