class AddDisableReasonToDdtFeatureModuleConfig < ActiveRecord::Migration
  def change
    add_column :ddt_feature_modules_configs, :disable_reason, :string
  end
end
