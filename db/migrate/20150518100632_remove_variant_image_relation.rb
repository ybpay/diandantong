class RemoveVariantImageRelation < ActiveRecord::Migration
  def change
    remove_column :ddt_assets, :viewable_type if column_exists? :ddt_assets, :viewable_type
    remove_column :ddt_assets, :viewable_id if column_exists? :ddt_assets, :viewable_id
    remove_column :ddt_assets, :position if column_exists? :ddt_assets, :position
  end
end
