class AddEnabledToFeatureModulesConfig < ActiveRecord::Migration
  def change
    add_column :ddt_feature_modules_configs, :enabled, :boolean, default: true
  end
end
