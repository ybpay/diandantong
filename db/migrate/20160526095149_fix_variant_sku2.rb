class FixVariantSku2 < ActiveRecord::Migration
  def change
    execute <<-SQL.strip_heredoc
      UPDATE ddt_combo_package_items AS ci
      LEFT JOIN ddt_variants AS v ON ci.variant_id = v.id
      SET ci.sku = v.sku
      WHERE ci.sku = CONCAT('', v.product_id)
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items AS l
      LEFT JOIN ddt_variants AS v ON l.itemable_id = v.id
      SET l.sku = v.sku
      WHERE l.itemable_type='Ddt::Variant' AND l.sku = CONCAT('', v.product_id)
    SQL


    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items AS l
      LEFT JOIN ddt_variant_packages AS vp ON l.itemable_id = vp.id
      LEFT JOIN ddt_variants AS v on vp.variant_id = v.id
      SET l.sku = v.sku
      WHERE l.itemable_type='Ddt::VariantPackage' AND l.sku = CONCAT('', v.product_id)
    SQL
  end
end
