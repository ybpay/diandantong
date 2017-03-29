class AddCityCode < ActiveRecord::Migration
  def change
  	
    add_column :ddt_shops, :city_code, :string, limit: 191
    add_column :ddt_agent_zones, :city_code, :string, limit: 191

    add_index :ddt_shops, :city_code
    add_index :ddt_agent_zones, :city_code
  end
end
