class AddAgentIdToShopRechargeRecords < ActiveRecord::Migration
  def change
    add_column :ddt_shop_recharge_records, :agent_id, :integer
  end
end
