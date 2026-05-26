class AddProductNameToLineItem < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_line_items
      SET product_name = CASE
        WHEN itemable_name ~ '\[.+\]$' THEN
          REPLACE(itemable_name, '[' || SUBSTRING(itemable_name FROM '\[([^\]]+)\]$'), '')
        WHEN itemable_name ~ '\(.+\)$' THEN
          REPLACE(itemable_name, '(' || SUBSTRING(itemable_name FROM '\(([^)]+)\)$'), '')
        ELSE itemable_name
      END
      WHERE itemable_name ~ '(\[.+\])|(\(.+\))$';
    SQL
  end

  def down
  end
end
