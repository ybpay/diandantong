class AddLisenceIdToShopRechargeRecords < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shop_recharge_records, :lisence_id
      add_column :ddt_shop_recharge_records, :lisence_id, :integer
    end
  end
end
