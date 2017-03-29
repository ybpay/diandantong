class FixComboPackageItemPrice < ActiveRecord::Migration

  def change
    fix_price
    fix_adjustment
  end

  def fix_price
    count = 0
    total = Ddt::ComboPackage.where("created_at > '2015-11-01 00:00:00'").count
    puts "total combo_package is #{total}"
    new_combo_package_items = []
    current_combo_package = nil
    Ddt::ComboPackage.where("created_at > '2015-11-01 00:00:00'").find_each do |combo_package|
      current_combo_package = combo_package
      combo_package_items = combo_package.combo_package_items
      combo_items = Ddt::ComboItem.where(id: combo_package_items.map(&:combo_item_id).uniq)
      combo_item_variants = Ddt::ComboItemsVariant.where(combi_id: combo_package_items.map(&:combi_id))
      variants = Ddt::Variant.with_deleted.where(id: combo_package_items.map(&:variant_id))
      if combo_package_items.blank? 
        next
      end
      new_combo_package_items << Ddt::ComboPackageItem.set_prices_with(combo_package_items, combo_items, combo_item_variants, variants)
      count += 1
      if count % 100 == 0
        save_combo_package_items(new_combo_package_items.flatten)
        new_combo_package_items = []
        puts "FixPrice #{(count.to_f/total).round(2)}: #{count}th: #{current_combo_package.id}" 
      end
    end
    if new_combo_package_items.size > 0
      save_combo_package_items(new_combo_package_items.flatten)
      puts "FixPrice #{(count.to_f/total).round(2)}: #{count}th: #{current_combo_package.id}" 
    end
  end

  def save_combo_package_items(combo_package_items)
    ids = combo_package_items.map(&:id)
      when_price_str = ''
      when_vip_price_str = ''
      when_original_price_str = ''
      combo_package_items.each do |cpi|
        when_price_str += "WHEN #{cpi.id} THEN #{cpi.price} "
        when_original_price_str += "WHEN #{cpi.id} THEN #{cpi.original_price} "
        when_vip_price_str += "WHEN #{cpi.id} THEN #{cpi.vip_price} "
      end

      sql = "UPDATE ddt_combo_package_items
        SET price = case id
        #{when_price_str}
        END,
        vip_price = case id 
          #{when_vip_price_str}
        END,
        original_price = case id 
          #{when_original_price_str}
        END
        WHERE id IN (#{ids.join(',')})"
      ActiveRecord::Base.connection.execute sql
  end

  def fix_adjustment
    count = 0
    total = Ddt::LineItem.where(itemable_type: 'Ddt::ComboPackage', deleted_at: nil).where("adjustment_total != 0 or apportion_adjustment_total != 0 or not_actual_amount != 0").where("created_at > '2015-11-01 00:00:00'").count
    puts "total line_item is #{total}"
    Ddt::LineItem.where(itemable_type: 'Ddt::ComboPackage', deleted_at: nil).where("adjustment_total != 0 or apportion_adjustment_total != 0 or not_actual_amount != 0").where("created_at > '2015-11-01 00:00:00'").find_each do |line_item|
      set_adjustments(line_item)
      count += 1
      puts "FixAdjustment #{(count.to_f/total).round(2)}: #{count}th: #{line_item.id}" if count % 100 == 0
    end
    puts "Migrate of  done! fixed size: #{(@fixed_ids || []).size}"
  end


  def set_adjustments(line_item)
    @fixed_ids ||= []
    return if @fixed_ids.include?(line_item.id)
    Ddt::ComboPackageItem.set_adjustments(line_item)
    @fixed_ids << line_item.id
  end
end
