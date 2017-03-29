class AddBranchIdToFeatureModulesConfig < ActiveRecord::Migration
  def change
    if index_exists? :ddt_feature_modules_configs, :shop_id
      remove_index :ddt_feature_modules_configs, :shop_id
    end
    add_index :ddt_feature_modules_configs, [:shop_id, :feature_module], name: :"index_on_shop_id_feature_module"
  end
end
