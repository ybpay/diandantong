class AddBranchNumToShopRechargeRecord < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shop_recharge_records, :branch_num
      add_column :ddt_shop_recharge_records, :branch_num, :integer, default: 1
      Ddt::ShopRechargeRecord.where(recharge_type: :multiple).update_all(branch_num: 100)
    end
  end
end
