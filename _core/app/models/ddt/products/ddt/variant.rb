# encoding:utf-8
module Ddt
  class Variant < Ddt::Base
    include Ddt::SoftDeletable

    include Ddt::ListScope
    include Ddt::BelongsToBranch
    include Ddt::HasVipPrice
    MAX_STOCK_QUANTITY = 999999

    # relationships
    belongs_to :product, ->{with_deleted}, touch: true, inverse_of: :variants, class_name: 'Ddt::Product', foreign_key: :product_id
    delegate_belongs_to :product, :name, :description, :availabled_at, :unit_name, :min_quantity_for_order, :show_note_in_weixin, :enable_change_price
    delegate :tags, :tag_ids, :categories, :category_ids, :enable_discount, :enable_discount?, to: :product, allow_nil: true
    has_many :variants_variant_images, class_name: 'Ddt::VariantsVariantImage', dependent: :destroy
    has_many :images, class_name: 'Ddt::VariantImage', through: :variants_variant_images, source: :variant_image
    has_and_belongs_to_many :option_values, class_name: "Ddt::OptionValue", join_table: 'ddt_option_values_variants',
                            after_add: :update_cache_info_by_option_value, after_remove: :update_cache_info_by_option_value

    has_many :combo_items_variants, class_name: 'Ddt::ComboItemsVariant', dependent: :destroy
    has_many :combo_items, through: :combo_items_variants, class_name: 'Ddt::ComboItem'
    has_and_belongs_to_many :promotion_rules, class_name: "Ddt::PromotionRule", join_table: 'ddt_variants_promotion_rule'
    has_many :essential_products, class_name: 'Ddt::EssentialProduct', dependent: :destroy
    has_many :variant_packages, class_name: 'Ddt::VariantPackage'

    # validations
    validates :price, :vip_price, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 99990000}, presence: true
    validate :vip_price_lteq_price
    #TODO: SKU的校验还是有问题，有可能导致SKU跨product存在重复
    # validates_uniqueness_of :sku, scope: [:branch_id, :is_master, :deleted_at], if: :sku_changed?
    validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, less_than: MAX_INTEGER }
    validates :sale_quantity, numericality: { greater_than_or_equal_to: 0, less_than: MAX_INTEGER }
    validates :default_weight, numericality: {greater_than: 0}
    validates_inclusion_of :estimate_clear_reciprocal , in: [true,false]
    validates :nfc_code, uniqueness: { :scope => [:branch_id, :deleted_at]}, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SP_ID}, allow_blank: true

    # scopes
    acts_as_list scope: [:product_id, :deleted_at]

    # callbacks
    set_shop_and_branch_from :product
    after_create :update_cache_info
    before_save :assign_sku
    after_update :check_stock_quantity
    before_save :set_estimate_clear_false, if: :stock_quantity_changed?
    after_save :send_remove_estimate_clear_msg, if: :stock_quantity_changed?

    after_create :notify_product_update
    after_destroy :notify_product_update

    #加上此代码就会导致产品创建时没有分类
    # accepts_nested_attributes_for :product, :update_only => true

    def options_text(options = {})
      options.reverse_merge!(sep: ",")
      values = self.option_values.joins(:option_type).order('ddt_option_types.position asc')
      values.map(&:name).join(options[:sep])
    end

    def serialized_text(options = {})
      options.reverse_merge!(sep: ",")
      [id, sku, options_text(sep: "#"), price, vip_price, stock_quantity].join(options[:sep])
    end

    def option_value(opt_name)
      self.option_values.detect { |o| o.option_type.name == opt_name }.try(:name)
    end

    def name_with_options_text
      is_master ? name : "#{name}(#{options_text})"
    end

    def name_with_options_text_with_cache
      self.cache_name
    end
    alias_method_chain :name_with_options_text, :cache

    def select_json
      { id: self.id, name: self.name_with_options_text }
    end

    def sku_json
      { id: self.sku, name: "#{self.sku}-#{self.name_with_options_text}" }
    end

    def avatar
      self.images.present? ? self.images.first : self.product.images.first
    end

    def update_cache_info_by_option_value(option_value=nil)
      self.update_cache_info unless self.new_record?
    end

    def update_cache_info
      self.cache_name         = self.name_with_options_text_without_cache
      self.cache_options_text = self.options_text
      self.cache_image_url    = self.avatar.try(:attachment).try(:small).try(:url)
      self.save!
    end

    def assign_sku
      if self.sku.blank?
        if self.product.present? && self.is_master?
          self.sku = self.product.id
        else
          self.sku = self.id
        end
      end
    end

    def check_stock_quantity
      if self.stock_quantity == 0 and self.stock_quantity_was > 0
        Ddt::Notification::Event::Product::StockEmpty.create_and_send_notification(variant: self)
      end
    end

    def backend_show_path
      if self.is_master?
        "/backend/shops/#{self.shop.slug}/branches/#{self.branch_id}/products/#{self.product_id}"
      else
        "/backend/shops/#{self.shop.slug}/branches/#{self.branch_id}/products/#{self.product_id}/variants"
      end
    end

    concerning :EstimateClear do
      included do
        # todo
        # use one type column to save clear state
        scope :estimate_clear, ->{ where(estimate_clear: true) }
        scope :estimate_clear_reciprocal, ->{ where(estimate_clear_reciprocal: true) }
        scope :estimate_clear_or_reciprocal, ->{ where("estimate_clear = 1 or estimate_clear_reciprocal = 1")}

        def self.remove_estimate_clear_of(branch)
          branch.variants.estimate_clear_or_reciprocal.each(&:remove_estimate_clear)
        end

      end

      def add_estimate_clear(opts={})
        do_estimate_clear(is_reciprocal: false, notify_self: opts[:notify_self])
      end

      def add_estimate_clear_reciprocal(opts={})
        do_estimate_clear(is_reciprocal: true, quantity: opts[:quantity], notify_self: opts[:notify_self])
      end

      def remove_estimate_clear(opts={})
        quantity = opts[:quantity] || MAX_STOCK_QUANTITY
        undo_estimate_clear(is_reciprocal: false, quantity: quantity, notify_self: opts[:notify_self])
      end

      def remove_estimate_clear_reciprocal(opts={})
        quantity = opts[:quantity] || MAX_STOCK_QUANTITY
        undo_estimate_clear(is_reciprocal: true, quantity: quantity, notify_self: opts[:notify_self])
      end

      private

      def do_estimate_clear(options={})
        is_reciprocal = options[:is_reciprocal] || false
        quantity = options[:quantity] || 0
        return if is_reciprocal && quantity < 1
        self.estimate_clear = !is_reciprocal
        self.estimate_clear_reciprocal = is_reciprocal
        self.stock_quantity = quantity if is_reciprocal
        result = self.save
        if result
          update_product_estimate_clear
          msg_type = is_reciprocal ? :add_reciprocal : :add
          send_estimate_clear_msg msg_type, {
            cache_version: self.product.updated_at.to_i * 1000,
            product_id: self.product_id,
            variant_id: self.id,
            notify_self: options[:notify_self]
          }
        end
        result
      end

      def undo_estimate_clear(options={})
        self.estimate_clear = false
        self.estimate_clear_reciprocal = false
        self.stock_quantity = options[:quantity]
        result = self.save
        if result
          update_product_estimate_clear
          msg_type = (options[:is_reciprocal] || false) ? :remove_reciprocal : :remove
          send_estimate_clear_msg msg_type, {
            cache_version: self.product.updated_at.to_i * 1000,
            product_id: self.product_id,
            variant_id: self.id,
            notify_self: options[:notify_self]
          }
        end
        result
      end

      def update_product_estimate_clear
        #若所有variants都估清,product自动估清
        if self.estimate_clear?
          if self.is_master?
            self.product.update(estimate_clear: true)          if !self.product.estimate_clear?
          else
            if self.product.variants.map(&:estimate_clear).exclude?(false)
              self.product.update(estimate_clear: true)          if !self.product.estimate_clear?
            end
          end
        else
          self.product.update(estimate_clear: false)          if self.product.estimate_clear?
        end
      end

      def set_estimate_clear_false
        if self.stock_quantity_was == 0 && self.stock_quantity > 0 && self.estimate_clear_was
          self.estimate_clear = false
          self.estimate_clear_reciprocal = false
          true
        end
      end

      def send_remove_estimate_clear_msg
        if self.stock_quantity_was == 0 && self.stock_quantity > 0 && self.estimate_clear_was
          update_product_estimate_clear
          send_estimate_clear_msg :remove, {
            product_id: self.product_id,
            variant_id: self.id
          }
        end
      end

      def notify_product_update
        Ddt::ProductUpdaterWorker.perform_in(15.minutes, self.branch_id, self.branch.products_cache_version)
      end

      def send_estimate_clear_msg(action, options)
        options[:action] = action
        options[:terminal_id] = RequestStore.store[:terminal_id]
        options[:notify_self] ||= false
        self.branch.order_related_people.each do |account|
          WebposNotify.send_estimate_clear_msg(account.id, options)
        end
      end

    end

    def is_by_weight?
      by_weight?
    end
    alias_method :is_by_weight, :is_by_weight?

    concerning :ItemableMethod do
      included do
        include Itemable
        # column: vip_price stock_quantity sku
        # delegate to product: name unit_name stock_enough?:enable_discount,  enable_discount? min_quantity_for_order enable_change_price
        def product_name
          product.name
        end

        def original_price
          self.price
        end

        def itemable_name
          self.name_with_options_text
        end

        def stock_enough?(require_num=1)
          !estimate_clear? &&
          stock_quantity.present? && (stock_quantity >= require_num)
        end

        def avatar_url
          self.cache_image_url
        end

        def update_stock_quantity(line_item_quantity)
          self.decrement(:stock_quantity, line_item_quantity)
          self.update_column(:stock_quantity, self.stock_quantity)
        end

        def update_sale_quantity(line_item_quantity)
          self.increment(:sale_quantity, line_item_quantity)
          self.update_column(:sale_quantity, self.sale_quantity)
        end

        def rollback_stock_quantity(line_item_quantity)
          self.increment(:stock_quantity, line_item_quantity)
          self.update_column(:stock_quantity, self.stock_quantity)
        end

        def category_names
          if self.categories.nil?
            ''
          else
            self.categories.with_deleted.map(&:name).join(',')
          end
        end
      end
    end

  end
end
