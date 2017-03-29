class RemoveOnShelfFromVariants < ActiveRecord::Migration
  def change
    remove_column :ddt_variants , :on_shelf , :boolean
  end
end
