module Ddt
  class ComboPackage < Ddt::Base
    include BelongsToBranch
    replicated_model

    belongs_to_order
    belongs_to :combo, ->{with_deleted}, class_name: 'Ddt::Combo'
    has_many :combo_package_items, class_name: 'Ddt::ComboPackageItem', dependent: :destroy, inverse_of: :combo_package, autosave: true

    validates_presence_of :combo

    delegate :avatar_url, :name, :description, :unit_name, :stock_quantity, :enable_discount, :enable_discount?, :enable_change_price, :sku, to: :combo

    set_shop_and_branch_from :combo

    scope :with_deleted, ->{ }

    def each_item
      self.combo_package_items.each do |item|
        yield item.variant, item.quantity
      end
    end

    def name_with_items
      "#{name}[#{self.combo_package_items.map(&:name).join(',')}]"
    end

    def quantity_right?(allow_lacking = false)
      self.combo.combo_items.all? do |combo_item|
        # TODO allow_lacking 为 App 传过来参数, 现兼容之
        # 以后App开发需要把 allow_lacking 去除掉.
        if allow_lacking || !combo_item.is_necessary?
          compare_select_count_of(combo_item, :<=)
        else
          compare_select_count_of(combo_item, :==)
        end
      end
    end

    def cache_name
      self.itemable_name = self.name_with_items.truncate(250, separator: '')
      self.save
    end

    def deleted?
      false
    end

    concerning :ItemableMethod do
      include Itemable
      included do
        # column : itemable_name
        # delegate to combo : name sku price vip_price unit_name avatar_url
        def product_name
          combo.name
        end

        [:price, :vip_price, :original_price].each do |price_type|
          define_method price_type do
            combo_package_items.map(&price_type).inject(&:+) || 0
          end
        end

        def stock_enough?(require_num=1)
          true
        end

        def update_stock_quantity(line_item_quantity)
          Combo.update_counters(combo_id, stock_quantity: - line_item_quantity)
          self.combo_package_items.each do |item|
            item.variant.decrement!(:stock_quantity, item.quantity * line_item_quantity)
          end
        end

        def update_sale_quantity(line_item_quantity)
          Combo.update_counters(combo_id, sale_quantity: line_item_quantity)
          self.combo_package_items.each do |item|
            item.variant.increment!(:sale_quantity, item.quantity * line_item_quantity)
          end
        end

        def rollback_stock_quantity(line_item_quantity)
          Combo.update_counters(combo_id, stock_quantity: line_item_quantity)
          self.combo_package_items.each do |item|
            item.variant.increment!(:stock_quantity, item.quantity * line_item_quantity)
          end
        end

        def to_stockables
          stockables = []
          self.combo_package_items.each do |item|
            item.quantity.times{|i| stockables << item.variant}
          end
          stockables
        end

      end
    end

    private

    def compare_select_count_of(combo_item, comparison_operator)
      combo_package_items_by(combo_item).map{|i| i.quantity}.sum.send(comparison_operator, combo_item.select_count)
    end

    def combo_package_items_by(combo_item)
      combo_package_items_with_cache.select{|item| item.combo_item_id == combo_item.id}
    end

    def combo_package_items_with_cache
      @combo_package_items_with_cache ||= combo_package_items
    end

  end
end
