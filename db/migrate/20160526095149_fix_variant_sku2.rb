class FixVariantSku2 < ActiveRecord::Migration
  def change
    execute <<-SQL.strip_heredoc
      UPDATE ddt_combo_package_items ci
      SET sku = v.sku
      FROM ddt_variants v
      WHERE ci.variant_id = v.id
        AND ci.sku = v.product_id::text
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items l
      SET sku = v.sku
      FROM ddt_variants v
      WHERE l.itemable_id = v.id
        AND l.itemable_type = 'Ddt::Variant'
        AND l.sku = v.product_id::text
    SQL

    execute <<-SQL.strip_heredoc
      UPDATE ddt_line_items l
      SET sku = v.sku
      FROM ddt_variant_packages vp
      JOIN ddt_variants v ON vp.variant_id = v.id
      WHERE l.itemable_id = vp.id
        AND l.itemable_type = 'Ddt::VariantPackage'
        AND l.sku = v.product_id::text
    SQL
  end
end
