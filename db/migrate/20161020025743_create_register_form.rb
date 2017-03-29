class CreateRegisterForm < ActiveRecord::Migration
  def change
    create_table :ddt_register_forms do |t|
      t.string :access_token
      t.string :phone
      t.string :name
      t.string :email
      t.string :login_id
      t.string :captcha
      t.string :captcha_id
      t.string :shop_agent_no
      t.integer :shop_id
      t.string :shop_address
      t.boolean :accept_term, default: true

      t.timestamps
    end
  end

end