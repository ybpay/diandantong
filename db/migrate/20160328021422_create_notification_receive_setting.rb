class CreateNotificationReceiveSetting < ActiveRecord::Migration
  def change
    unless table_exists? :ddt_notification_receive_settings
      create_table :ddt_notification_receive_settings do |t|
        t.references :shop, index: true
        t.references :account, index: true
        t.text :settings
        t.timestamps
      end
    end
    Ddt::Account.all.find_each do |account|
      account.create_notification_receive_setting!
    end
  end
end
