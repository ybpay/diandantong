class AddProductNameToLineItem < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_line_items
      SET product_name = CASE
        WHEN itemable_name ~ '\[[^\]]+\]$' THEN
          regexp_replace(itemable_name, '\[[^\]]+\]$', '')
        WHEN itemable_name ~ '\([^)]+\)$' THEN
          regexp_replace(itemable_name, '\([^)]+\)$', '')
        ELSE itemable_name
      END
      WHERE itemable_name ~ '(\[.+\])|(\(.+\))$';
    SQL
  end

  def down
  end
end
