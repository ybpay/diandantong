class AddProductNameToLineItem < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_line_items line_item
      SET
        line_item.product_name = if(itemable_name REGEXP '\\\\[.+\\\\]$',
        REPLACE(itemable_name,
            CONCAT('[',
                    SUBSTRING_INDEX(itemable_name, '[', - 1)),
            ''),
        if(itemable_name REGEXP '\\\\(.+\\\\)$',
            REPLACE(itemable_name,
                CONCAT('(',
                        SUBSTRING_INDEX(itemable_name, '(', - 1)),
                ''),
            itemable_name))
      where line_item.itemable_name REGEXP '(\\\\[.+\\\\])|(\\\\(.+\\\\))$';
    SQL
  end

  def down
  end
end
