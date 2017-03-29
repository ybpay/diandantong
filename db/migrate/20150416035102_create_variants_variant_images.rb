class CreateVariantsVariantImages < ActiveRecord::Migration
  def change
    create_table :ddt_variants_variant_images do |t|
      t.references :variant, index: true
      t.references :variant_image, index: true
      t.integer :position
    end
  end
end
