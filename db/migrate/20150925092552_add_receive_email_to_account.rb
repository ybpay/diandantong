class AddReceiveEmailToAccount < ActiveRecord::Migration
  def change
  	add_column :ddt_accounts, :receive_email, :boolean, default: false
  end
end
