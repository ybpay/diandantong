# encoding: utf-8
module Ddt
  module ProductCopy
    extend ActiveSupport::Concern
    included do
    end


    def self.copy_products_to_branchs(products, branches, replace_same_product)
      skiped_product_msgs = ""
      # copy variant image
      copy_image = ->(variant, new_variant){
        variant.images.each do |image|
          new_variant.images << image
        end
      }

      # copy variant option_value
      copy_option_value = ->(variant, new_variant, branch_id){
        variant.option_values.each do |option_value|
          new_option_value = Ddt::OptionValue.find_by(branch_id: branch_id, name: option_value.name)
          new_variant.option_values << new_option_value if new_option_value.present?
        end
      }

      # copy variant
      copy_variant = ->(variant, new_variant, branch_id){
        params = build_params(variant, except_columns: %W(stock_quantity sale_quantity product_id)).merge(branch_id: branch_id)
        params.each do |k, v|
          new_variant.send "#{k}=", v
        end
        new_variant.save!
      }

      branches.each do |branch|
        duplicate_products = []
        unsolved_combos_and_variants = {}

        products.each do |product|
          if product.sku.blank?
            new_product = branch.products.find_by(name: product.name)
          else
            new_product = branch.products.joins(:master).where("ddt_variants.sku = ?", product.sku).first
          end

          if replace_same_product && new_product
            # copy printers and combo
            printer_ids = new_product.printers.pluck(:id)
            baned_printer_ids = new_product.baned_printers.pluck(:id)
            # copy combo_item_variants
            # map: variant sku -> combo_item_ids
            combo_items_map = {}
            build_variant_combo_items_map(combo_items_map, new_product.master)
            new_product.variants.map do |variant|
              build_variant_combo_items_map(combo_items_map, variant)
            end

            new_product.destroy
            new_product = nil
          end

          if new_product.blank?

            # category
            category_ids_string = product.categories.with_deleted.map do |category|
              branch.categories.find_or_create_by(name: category.name)
            end.map(&:id).join(",")


            # create product
            master_params = build_params(product.master, only_columns: %W(price vip_price is_master sku)).merge(branch_id: branch.id)
            product_params = build_params(product).merge(master_params).merge(category_ids_string: category_ids_string)
            new_product = branch.products.create!(product_params)


            product.option_types.each do |option_type|
              new_option_type = branch.option_types.find_by(name: option_type.name)
              unless new_option_type.present?
                new_option_type = branch.option_types.create(name: option_type.name)
                option_type.option_values.each do |option_value|

                  new_option_type.option_values.create(name: option_value.name)
                end
              end
              new_product.option_types << new_option_type
            end

            # master's image and option value
            copy_variant.call(product.master, new_product.master, branch.id)
            copy_image.call(product.master, new_product.master)
            copy_option_value.call(product.master, new_product.master, branch.id)
            copy_combo_item_variant_relation(combo_items_map, new_product.master)

            # other variants
            product.variants.each do |variant|
              new_variant = new_product.variants.new
              copy_variant.call(variant, new_variant, branch.id)
              copy_image.call(variant, new_variant)
              copy_option_value.call(variant, new_variant, branch.id)
              copy_combo_item_variant_relation(combo_items_map, new_variant)
            end

            if combo_items_map.present?
              # 有套餐无法保持，令之失败
              unsolved_combo_item_ids = combo_items_map.values.flatten.uniq
              unsolved_combos = branch.combo_items.where(id: unsolved_combo_item_ids).map(&:combo).map(&:name)
              relate_product_name = product.name
              skiped_product_msgs << "门店#{branch.name}产品#{relate_product_name}和以下套餐不匹配：(#{unsolved_combos}), 自动忽略复制。"
              next
            end

            # tag
            product.tags.each do |tag|
              new_product.tags << branch.product_tags.find_or_create_by(name: tag.name)
            end

            # printers
            new_product.printers << branch.printers.where(id: printer_ids) if printer_ids.present?
            new_product.baned_printers << branch.printers.where(id: baned_printer_ids) if baned_printer_ids.present?

            # new_product.save!
            new_product.update_variants_cache_info

          else
            duplicate_products << product
          end
        end
        if duplicate_products.present?
          names_str = duplicate_products.map(&:name).join(",")
          skiped_product_msgs << "门店#{branch.name}有同名产品：(#{names_str}), 自动忽略复制。"
        end
      end
      skiped_product_msgs
    end

    def self.copy_combo_item_variant_relation(map, variant)
      if map.present?
        key = variant.options_text
        combo_item_ids = map[key]
        if combo_item_ids.present?
          combo_items = variant.branch.combo_items.where(id: combo_item_ids)
          variant.combo_items << combo_items if combo_items.present?
          map.delete(key)
        end
      end
    end

    def self.build_variant_combo_items_map(map, variant)
      combo_item_ids = variant.combo_items_variants.pluck(:combo_item_id)
      map[variant.options_text] = combo_item_ids if combo_item_ids.present?
    end

    def self.build_params(obj, options={})
      only_columns = options[:only_columns] || []
      except_columns = options[:except_columns] || []
      if only_columns.present?
        column_names = only_columns
      else
        column_names = obj.class.column_names - except_columns - %W[branch_id id created_at updated_at deleted_at]
      end
      params = {}
      column_names.each do |column_name|
        params[column_name] = obj.send column_name
      end
      params
    end

    def self.copy_combos_to_branches(combos, branches)
      message = []
      branches.each do |branch|
        not_find_variant_combos = []
        error_combos = []
        duplicate_combos = []
        combos.each do |combo|
          begin
            Ddt::Combo.transaction do
              new_combo = branch.combos.find_by(name: combo.name)
              if new_combo.blank?
                new_combo = branch.combos.build(build_params(combo, except_columns: %W(stock_quantity sale_quantity)))
                new_combo.save!
                combo.combo_items.each do |combo_item|
                  variants = combo_item.variants
                  new_combo_item = new_combo.combo_items.build(
                    name: combo_item.name,
                    select_count: combo_item.select_count,
                    is_necessary: combo_item.is_necessary,
                    price: combo_item.price,
                    vip_price: combo_item.vip_price,
                    original_price: combo_item.original_price,
                    price_strategy: combo_item.price_strategy
                  )
                  variants.each do |variant|
                    find_variant = branch.variants.find_by(cache_name: variant.cache_name)
                    if find_variant.present?
                      combo_items_variant = combo_item.combo_items_variants.find_by(variant_id: variant.id)
                      params = build_params(combo_items_variant, except_columns: %W(combo_item_id variant_id combi_id)).merge(variant_id: find_variant.id, combo_item_id: new_combo_item.id)
                      new_combo_item.combo_items_variants.build(params)
                    else
                      not_find_variant_combos << combo
                      raise ActiveRecord::Rollback
                    end
                  end
                  new_combo_item.save!
                end
              else
                duplicate_combos << combo
              end
            end
          rescue ActiveRecord::RecordInvalid => e
            error_combos << { combo: combo, message: e.message }
          end
        end
        message << "门店#{branch.name}中套餐(#{not_find_variant_combos.map(&:name).join(',')}), 因未找到对应产品不能复制。" if not_find_variant_combos.present?
        message << "门店#{branch.name}中有同名套餐(#{duplicate_combos.map(&:name).join(',')}), 自动忽略复制。" if duplicate_combos.present?
        message << "门店#{branch.name}中有套餐(#{error_combos.map{|h| "[#{h[:combo].name}, #{h[:message]}]" }.join(',')})校验不通过, 不能复制。" if error_combos.present?
      end
      message.join("")
    end

  end
end
