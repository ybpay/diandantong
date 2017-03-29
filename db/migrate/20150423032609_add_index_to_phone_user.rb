class AddIndexToPhoneUser < ActiveRecord::Migration
  def change
    add_index :ddt_base_users, :phone
  end
end
