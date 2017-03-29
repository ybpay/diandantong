class AddExtraCredtisToRechargeProduct < ActiveRecord::Migration
  def change
    add_column :ddt_recharge_products, :extra_credits, :integer, default: 0
  end
end
