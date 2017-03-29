class RemoveFeatureModule < ActiveRecord::Migration
  def change
    if ActiveRecord::Migration.table_exists? :ddt_feature_modules 
      drop_table :ddt_feature_modules
    end
  end
end
