class OptDbProformance < ActiveRecord::Migration
  def change
  	change_column :ddt_message_receptions, :from_user_name, :string, limit: 191
  	change_column :ddt_message_receptions, :to_user_name, :string, limit: 191
    add_index :ddt_message_receptions, :from_user_name
    add_index :ddt_message_receptions, :to_user_name
    add_index :ddt_message_receptions, :created_at
  end
end
