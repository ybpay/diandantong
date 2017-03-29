class AddColumnToBaseuser < ActiveRecord::Migration
  def change
  	add_column :ddt_base_users, :wifi_code, :string
  end
end
