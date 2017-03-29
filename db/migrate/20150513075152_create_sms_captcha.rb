class CreateSmsCaptcha < ActiveRecord::Migration
  def change
    create_table :ddt_sms_captchas do |t|
      t.string :code
      t.string :phone
      t.string :ip
      t.boolean :validated, default: false
      t.timestamps
    end

    add_index :ddt_sms_captchas, :phone
    add_index :ddt_sms_captchas, :ip
  end
end
