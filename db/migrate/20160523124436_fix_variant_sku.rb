class FixVariantSku < ActiveRecord::Migration
  def change
    Ddt::Variant.where("sku = concat('', product_id)").update_all("sku = id")
  end
end
