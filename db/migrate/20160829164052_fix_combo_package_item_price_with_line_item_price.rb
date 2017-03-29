class FixComboPackageItemPriceWithLineItemPrice < ActiveRecord::Migration
  def change
    
    sql1 = <<-SQL
      select combo_package_id, line_item_price, line_item_vip_price, cpi_price from (select l.itemable_id as combo_package_id, l.price as line_item_price, l.vip_price as line_item_vip_price, sum(cpi.price) as cpi_price from ddt_line_items as l
      inner join ddt_combo_package_items as cpi 
      on l.itemable_id = cpi.combo_package_id
      where l.itemable_type = 'Ddt::ComboPackage'
      group by l.itemable_id, l.price, l.vip_price) as a
      where line_item_price != cpi_price
    SQL
    
    result = ActiveRecord::Base.connection.execute sql1
    result.to_a.each do |line|
      combo_package_id = line[0]
      price = line[1]
      vip_price = line[2]
      combo_package_items = Ddt::ComboPackageItem.where(combo_package_id: combo_package_id)
      set_prices(combo_package_items, price, vip_price)
    end
  end


  def set_prices(combo_package_items, price, vip_price)
      # 注: 为了解决除不尽问题， 这里的价格字段(price, vip_price, original_price), 实际上是已经乘上数量的小计.
      variants = Ddt::Variant.with_deleted.where(id: combo_package_items.map(&:variant_id))
      combo_package_items = set_prices_with(combo_package_items, variants, price, vip_price)

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

  def set_prices_with(combo_package_items, variants, combo_package_price, combo_package_vip_price)
    combo_package_original_price = combo_package_items.map do |pitem|
      variant = variants.detect{|i| i.id == pitem.variant_id}
      variant.price * pitem.quantity
    end.sum

    # set_price
    combo_package_items.each do |pitem|
      variant = variants.detect{|i| i.id == pitem.variant_id}
      rate = 1.0 
      if combo_package_original_price != 0
        rate =  1.0 * variant.price * pitem.quantity / combo_package_original_price
      end
      pitem.price          = (rate * combo_package_price).round_to_floor(2)
      pitem.vip_price      = (rate * combo_package_vip_price).round_to_floor(2)
      pitem.original_price = (rate * combo_package_original_price).round_to_floor(2)
    end

    diff1 = (combo_package_price          - combo_package_items.map(&:price).sum).round(2)
    diff2 = (combo_package_vip_price      - combo_package_items.map(&:vip_price).sum).round(2)
    diff3 = (combo_package_original_price - combo_package_items.map(&:original_price).sum).round(2)

    combo_package_items[0].price          += diff1
    combo_package_items[0].vip_price      += diff2
    combo_package_items[0].original_price += diff3

    combo_package_items
  end
end
