class ChangeLastPushItemNo < ActiveRecord::Migration
  def change
    remove_column :ddt_queue_settings, :last_push_queue_item_no
    add_column :ddt_queue_settings, :last_push_queue_item_no, :integer, default: 0
  end
end
