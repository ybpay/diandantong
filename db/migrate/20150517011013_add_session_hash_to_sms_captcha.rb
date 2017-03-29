class AddSessionHashToSmsCaptcha < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_sms_captchas, :session_hash
      add_column :ddt_sms_captchas, :session_hash, :string, limit: 191
      add_index :ddt_sms_captchas, :session_hash
    end
  end
end
