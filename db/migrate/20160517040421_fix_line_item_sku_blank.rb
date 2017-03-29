class FixLineItemSkuBlank < ActiveRecord::Migration
  def change

    execute <<-SQL
      UPDATE ddt_line_items AS l
      LEFT JOIN ddt_variants AS v ON l.itemable_id = v.id
      SET l.sku = v.sku
      WHERE l.itemable_type='Ddt::Variant' AND l.sku = ''
    SQL

    execute <<-SQL
      UPDATE ddt_line_items AS l
      LEFT JOIN ddt_combo_packages AS cp ON l.itemable_id = cp.id
      LEFT JOIN ddt_combos AS c ON cp.combo_id = c.id
      SET l.sku = c.sku
      WHERE l.itemable_type='Ddt::Combopackage' AND l.sku = ''
    SQL

    execute <<-SQL
      UPDATE ddt_line_items AS l
      LEFT JOIN ddt_variant_packages AS vp ON l.itemable_id = vp.id
      LEFT JOIN ddt_variants AS v on vp.variant_id = v.id
      SET l.sku = v.sku
      WHERE l.itemable_type='Ddt::VariantPackage' AND l.sku = ''
    SQL

  end
end
