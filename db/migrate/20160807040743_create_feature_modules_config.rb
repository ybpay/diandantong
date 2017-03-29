class CreateFeatureModulesConfig < ActiveRecord::Migration
  def change
    unless table_exists? :ddt_feature_modules_configs
      create_table :ddt_feature_modules_configs do |t|
        t.integer :shop_id
        t.string :feature_module
        t.datetime :expired_at
        t.timestamps
      end
    end

    unless index_exists? :ddt_feature_modules_configs, :shop_id
      add_index :ddt_feature_modules_configs, :shop_id
    end
  end
end
