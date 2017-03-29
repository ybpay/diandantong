class AddVariantToNotificationEvent < ActiveRecord::Migration
  def change
    add_column :ddt_notification_events, :variant_id, :integer
  end
end
