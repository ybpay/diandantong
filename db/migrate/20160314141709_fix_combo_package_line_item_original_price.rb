class FixComboPackageLineItemOriginalPrice < ActiveRecord::Migration

  def up
    collection = []
    Ddt::LineItem.where(itemable_type: 'Ddt::ComboPackage').find_each do |line_item|
      collection << line_item
      if collection.size == 100
        fix_original_price(collection)
        collection = []
      end
    end
    if collection.size > 0
      fix_original_price(collection)
    end
  end

  def down
    Ddt::LineItem.where(itemable_type: 'Ddt::ComboPackage').update_all('original_price = price')
  end


  def fix_original_price(line_items)
    collection = []
    combo_packages = Ddt::ComboPackage.where(id: line_items.map(&:itemable_id))
    line_items.each do |line_item|
      combo_package = combo_packages.detect{|combo_package| combo_package.id == line_item.itemable_id}
      if combo_package.present?

        original_price = combo_package.original_price
        if original_price != line_item.price
          collection << {line_item_id: line_item.id, original_price: original_price}
        end

      end
    end
    if collection.size > 0
      sql = []
      sql << "update ddt_line_items"
      sql << "set original_price = case id"
      collection.each do |item|
        sql << " when #{item[:line_item_id]} then #{item[:original_price]}"
      end
      sql << " end"
      sql << " where id in (#{line_items.map(&:id).join(',')})"
      execute sql.join(" ")
    end
  end

end
