class AddSkuToLineItem < ActiveRecord::Migration
  def up
    add_column :ddt_line_items, :sku, :string unless column_exists? :ddt_line_items, :sku
    execute <<-SQL.strip_heredoc
      update ddt_line_items l
        left join ddt_variants v on v.id = l.itemable_id
        set
          l.sku = v.sku
        where l.itemable_type = 'Ddt::Variant';
    SQL
    execute <<-SQL.strip_heredoc
      update ddt_line_items l
        left join ddt_combo_packages cp on cp.id = l.itemable_id
        left join ddt_combos c on c.id = cp.combo_id
        set
          l.sku = c.sku
        where l.itemable_type = 'Ddt::ComboPackage';
    SQL
    execute <<-SQL.strip_heredoc
      update ddt_line_items l
        left join ddt_variant_packages vp on vp.id = l.itemable_id
        left join ddt_variants v on v.id = vp.variant_id
        set
          l.sku = v.sku
        where l.itemable_type = 'Ddt::VariantPackage';
    SQL
  end

  def down
    remove_column :ddt_line_items, :sku, :string if column_exists? :ddt_line_items, :sku
  end
end
