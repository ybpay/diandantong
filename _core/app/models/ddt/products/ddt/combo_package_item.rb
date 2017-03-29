module Ddt
  class ComboPackageItem < Ddt::Base
    include BelongsToBranch
    replicated_model

    belongs_to :combo_package, class_name: 'Ddt::ComboPackage'
    belongs_to :combo_item, class_name: 'Ddt::ComboItem'
    belongs_to :variant, ->{ with_deleted }, class_name: 'Ddt::Variant'

    validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

    set_shop_and_branch_from :combo_package

    def combo_item_variant
      @combo_item_variant ||= Ddt::ComboItemsVariant.find_by(combi_id: combi_id)
    end

    def combi_id
      "#{combo_item_id}:#{variant_id}"
    end

    def name
      "#{self.variant.name_with_options_text}*#{self.quantity}"
    end


    def self.set_prices(combo_package_items)
      # 注: 为了解决除不尽问题， 这里的价格字段(price, vip_price, original_price), 实际上是已经乘上数量的小计.
      combo_items = Ddt::ComboItem.where(id: combo_package_items.map(&:combo_item_id).uniq)
      combo_item_variants = Ddt::ComboItemsVariant.where(combi_id: combo_package_items.map(&:combi_id))
      variants = Ddt::Variant.with_deleted.where(id: combo_package_items.map(&:variant_id))
      combo_package_items = set_prices_with(combo_package_items, combo_items, combo_item_variants, variants)

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


    def self.set_prices_with(combo_package_items, combo_items, combo_item_variants, variants)
      # 算出整个套餐的价格
      combo_package_price = 0
      combo_package_vip_price = 0
      combo_package_items.group_by(&:combo_item_id).each do |combo_item_id, package_items|
        combo_item = combo_items.detect{|i| i.id == combo_item_id}
        if combo_item.present?
          if combo_item.is_fixed_price?
            combo_package_price += combo_item.price
            combo_package_vip_price += combo_item.vip_price
          elsif combo_item.is_dynamic_price?
            package_items.each do |pitem|
              cv = combo_item_variants.detect{|i| i.combi_id == pitem.combi_id}
              quantity = pitem.quantity
              if cv.present?
                combo_package_price += cv.price * quantity
                combo_package_vip_price += cv.vip_price * quantity
              end
            end
          end
        end
      end

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

    def self.set_adjustments(line_item)
      package_items = line_item.itemable.combo_package_items
      if line_item.adjustment_total == 0 && 
        line_item.apportion_adjustment_total == 0 &&
        line_item.not_actual_amount == 0 && 
        package_items.all?{|pi| pi.adjustment_total == 0 && pi.apportion_adjustment_total == 0 && pi.not_actual_amount == 0}
        return 
      end
      if package_items.present?
        sum_price = package_items.map(&:price).inject(&:+)
        if sum_price > 0.0
          package_items.each_with_index do |pitem, index|
            rate = 1.0 * pitem.price / sum_price
            pitem.adjustment_total           = (rate * line_item.adjustment_total).round_to_floor(2)
            pitem.apportion_adjustment_total = (rate * line_item.apportion_adjustment_total).round_to_floor(2)
            pitem.not_actual_amount          = (rate * line_item.not_actual_amount).round_to_floor(2)
          end
        end

        diff1 = (line_item.adjustment_total           - package_items.map(&:adjustment_total).sum).round(2)
        diff2 = (line_item.apportion_adjustment_total - package_items.map(&:apportion_adjustment_total).sum).round(2)
        diff3 = (line_item.not_actual_amount          - package_items.map(&:not_actual_amount).sum).round(2)

        package_items[0].adjustment_total           += diff1
        package_items[0].apportion_adjustment_total += diff2
        package_items[0].not_actual_amount          += diff3

        #批量保存提高效率
        ids = package_items.map(&:id)
        when_adjustment_total_str = ''
        when_apportion_adjustment_total_str = ''
        when_not_actual_amount_str = ''
        package_items.each do |cpi|
          when_adjustment_total_str += "WHEN #{cpi.id} THEN #{cpi.adjustment_total} "
          when_apportion_adjustment_total_str += "WHEN #{cpi.id} THEN #{cpi.apportion_adjustment_total} "
          when_not_actual_amount_str += "WHEN #{cpi.id} THEN #{cpi.not_actual_amount} "
        end

        sql = "UPDATE ddt_combo_package_items
          SET adjustment_total = case id
          #{when_adjustment_total_str}
          END,
          apportion_adjustment_total = case id 
            #{when_apportion_adjustment_total_str}
          END,
          not_actual_amount = case id 
            #{when_not_actual_amount_str}
          END
          WHERE id IN (#{ids.join(',')})"
        ActiveRecord::Base.connection.execute sql
      end
    end

  end
end
