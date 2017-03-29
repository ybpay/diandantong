class AddUseBirthdaySmsToShortMessageSetting < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_short_message_settings, :use_birthday_sms
      add_column :ddt_short_message_settings, :use_birthday_sms, :boolean, default: false
      add_column :ddt_short_message_settings, :birthday_message, :string
    end
  end
end
