class AddShareMultiPromotionToBranch < ActiveRecord::Migration
  def change
    if !column_exists? :ddt_branches, :share_multi_promotion
      add_column :ddt_branches, :share_multi_promotion, :boolean, default: false
    end
  end
end
