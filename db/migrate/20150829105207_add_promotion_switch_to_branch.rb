class AddPromotionSwitchToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :promotion_in_webpos, :boolean, default: false
  end
end
