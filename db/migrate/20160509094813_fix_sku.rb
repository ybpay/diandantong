class FixSku < ActiveRecord::Migration
  def change

    Ddt::Variant.with_deleted.where("sku IS NULL or sku=''").update_all('sku=product_id')
    Ddt::Combo.with_deleted.where("sku IS NULL or sku=''").update_all('sku=id')

    unless column_exists? :ddt_combo_package_items, :sku
      add_column :ddt_combo_package_items, :sku, :string
    end

    execute <<-SQL
      UPDATE ddt_combo_package_items AS ci
      LEFT JOIN ddt_variants AS v ON ci.variant_id = v.id
      SET ci.sku = v.sku
    SQL

    execute <<-SQL
      UPDATE ddt_line_items AS l 
      LEFT JOIN ddt_variants AS v ON l.itemable_id = v.id
      SET l.sku = v.sku
      WHERE l.itemable_type='Ddt::Variant' AND l.sku IS NULL
    SQL

    execute <<-SQL
      UPDATE ddt_line_items AS l 
      LEFT JOIN ddt_combo_packages AS cp ON l.itemable_id = cp.id
      LEFT JOIN ddt_combos AS c ON cp.combo_id = c.id
      SET l.sku = c.sku
      WHERE l.itemable_type='Ddt::Combopackage' AND l.sku IS NULL
    SQL

    execute <<-SQL
      UPDATE ddt_line_items AS l
      LEFT JOIN ddt_variant_packages AS vp ON l.itemable_id = vp.id
      LEFT JOIN ddt_variants AS v on vp.variant_id = v.id
      SET l.sku = v.sku
      WHERE l.itemable_type='Ddt::VariantPackage' AND l.sku IS NULL
    SQL

  end
end
