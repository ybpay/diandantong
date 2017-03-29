class RemoveUnusedField < ActiveRecord::Migration
  def change
    if column_exists? :ddt_shop_recharge_records, :feature_module_group
      remove_column :ddt_shop_recharge_records, :feature_module_group
    end
    if column_exists? :ddt_lisences, :feature_module_group
      remove_column :ddt_lisences, :feature_module_group
    end
  end
end
