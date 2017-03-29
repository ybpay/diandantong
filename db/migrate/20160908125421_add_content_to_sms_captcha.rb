class AddContentToSmsCaptcha < ActiveRecord::Migration
  def up
    add_column :ddt_sms_captchas, :short_message_id, :integer, index: true
  end
end
