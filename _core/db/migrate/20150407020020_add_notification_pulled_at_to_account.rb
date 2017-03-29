class AddNotificationPulledAtToAccount < ActiveRecord::Migration
  def change
    add_column :ddt_accounts, :notification_pulled_at, :datetime, :default => '2015-04-01 00:00:00'
  end
end
