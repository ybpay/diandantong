class CreateVariantPackage < ActiveRecord::Migration
  def change
    create_table :ddt_variant_packages do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.references :order, index: true
      t.references :variant, index: true
      t.string :itemable_name
      t.float :weight
      t.timestamps
    end
  end
end
