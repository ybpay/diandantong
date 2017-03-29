class AddNotifyNumberInAdvanceToQueueSetting < ActiveRecord::Migration
  def change
    add_column :ddt_queue_settings, :notify_number_in_advance, :integer, default: 100
  end
end
