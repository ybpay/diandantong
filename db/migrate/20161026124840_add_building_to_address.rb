class AddBuildingToAddress < ActiveRecord::Migration
  def change
    add_column :ddt_addresses, :building, :string
    add_column :ddt_addresses, :room_no, :string
    Ddt::Address.update_all("building = content")
    remove_column :ddt_addresses, :content
  end
end
