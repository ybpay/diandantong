class RemoveAgentZoneIdToShop < ActiveRecord::Migration
  def change
    remove_column :ddt_shops, :agent_zone_id, :integer
  end
end
