class AddIndexToSmsCaptcha < ActiveRecord::Migration
  def change
    add_index :ddt_sms_captchas, :updated_at
  end
end
