# encoding:utf-8
module Ddt
  class Product < Ddt::Base
    acts_as_paranoid

    include Ddt::BelongsToBranch
    include Ddt::Productable
    include Ddt::ProductImportExport
    include Ddt::Scanable
    include Ddt::HasManyTags

    filter_unicode_for :name, :description, :unit_name
    access_with_shop_time_zone :availabled_at
    skip_callback :create, :after, :create_qr_code
    include ListScope
    # acts_as_list scope: :branch_id

    # relationships
    has_one :master, -> { where is_master: true }, inverse_of: :product, class_name: 'Ddt::Variant', dependent: :destroy
    has_many :variants, -> { where(is_master: false).list_order }, class_name: 'Ddt::Variant', inverse_of: :product
    has_many :variants_including_master, -> { order(is_master: :desc, position: :asc) }, class_name: 'Ddt::Variant', inverse_of: :product, dependent: :destroy
    accepts_nested_attributes_for :variants_including_master, reject_if: :new_record?
    has_many :product_option_types, dependent: :destroy, inverse_of: :product, class_name: 'Ddt::ProductOptionType'
    has_many :option_types, through: :product_option_types, class_name: 'Ddt::OptionType'
    has_and_belongs_to_many :categories, -> { uniq }, after_add: :check_category_parent, class_name: 'Ddt::Category', join_table: 'ddt_categories_products',
                            after_add: :touch_categories, before_remove: :touch_categories

    has_and_belongs_to_many :printers, :join_table => 'ddt_printers_products', class_name: 'Ddt::Printer'
    has_and_belongs_to_many :baned_printers, :join_table => 'ddt_printers_ban_products', class_name: 'Ddt::Printer'
    has_and_belongs_to_many :accounts, :join_table => 'ddt_accounts_products', class_name: 'Ddt::Printer'
    has_and_belongs_to_many :item_notes, :join_table => 'ddt_item_notes_products', class_name: 'Ddt::ItemNote'

    ids_string_for :categories, :option_types, :item_notes

    delegate_belongs_to :master, :avatar_url, :price, :vip_price, :is_master, :sku, :stock_quantity, :sale_quantity, :by_weight, :by_weight?, :default_weight, :nfc_code
    delegate :images, to: :master, prefix: true
    alias_method :images, :master_images

    has_many :variant_images, -> { order(:position) }, source: :images, through: :variants_including_master


    # validations
    validates_presence_of :name, :unit_name, :availabled_at
    validates :categories, presence: true
    validates :min_quantity_for_order, numericality: { greater_than_or_equal_to: 1, less_than: MAX_INTEGER }

    # scopes
    default_scope ->{ list_order }
    scope :by_name, ->(name){ where('ddt_products.name like :keyword or ddt_products.name_abbr like :keyword', keyword: "%#{name}%") if name.present? }
    scope :on_shelf, ->() { where(on_shelf: true) }
    scope :estimate_clear, ->{where(estimate_clear: true)}
    scope :of_wechat, -> () {where(show_on_wechat: true)}

    # callbacks
    after_initialize :ensure_master
    after_create :set_master_variant_defaults
    after_save :save_master
    after_save :run_touch_callbacks, if: :anything_changed?
    after_save :reset_nested_changes
    after_save :update_variants_cache_info, if: :name_changed?
    before_save :reset_name_abbr, if: :name_changed?
    touch_cache_version_of_scope :branch

    # Master variant may be deleted (i.e. when the product is deleted)
    # which would make AR's default finder return nil.
    # This is a stopgap for that little problem.
    def master
      super || variants_including_master.with_deleted.where(is_master: true).first
    end

    def variants_and_option_values
      variants.includes(:option_values).select do |variant|
        variant.option_values.any?
      end
    end

    def allow_scan?(user=nil)
      true
    end

    # the master variant is not a member of the variants array
    def has_variants?
      variants.any?
    end

    def self.set_on_shelf(ids)
      where(id: ids).update_all(on_shelf: true, updated_at: Time.now)
    end

    def self.set_off_shelf(ids)
      where(id: ids).update_all(on_shelf: false, updated_at: Time.now)
    end

    def self.set_estimate_clear(ids)
      where(id: ids).update_all(estimate_clear: true, updated_at: Time.now)
      Variant.where(product_id: ids).update_all(estimate_clear: true, updated_at: Time.now)
    end

    def self.set_estimate_full(ids)
      where(id: ids).update_all(estimate_clear: false, updated_at: Time.now)
      Variant.where(product_id: ids).update_all(estimate_clear: false, updated_at: Time.now)
    end


    # 当用户扫码后目标对象为该model时，系统自动跳转的路由地址
    def weixin_path
      "?_ng_path=/branches/#{self.branch_id}/products/#{self.id}"
    end

    def select_json
      { id: self.id, name: name }
    end

    # 产品的总销量，如果有子类型则为子类型销量之和，如果没有子类型则是主类型销量
    def total_sale_quantity
      if self.variants.present?
        ### 线上系统中有sale_quantity是nil的情况，用compact去掉
        self.variants.map(&:sale_quantity).compact.sum
      else
        self.master.sale_quantity
      end
    end

     # add scope search for ransack
    def self.ransackable_scopes(auth_object = nil)
      [:by_category]
    end

    def disable_discount?
      !enable_discount?
    end

    def update_variants_cache_info
      self.variants_including_master.each(&:update_cache_info)
    end

    def category_ids
      categories.group('ddt_categories.id').reorder('min(ddt_categories.position)').pluck(:id)
    end

    private
    def set_master_variant_defaults
      self.master.is_master = true
    end

    def ensure_master
      self.master ||= Variant.new if new_record?
    end

    def anything_changed?
      changed? || @nested_changes
    end

    def reset_nested_changes
      @nested_changes = false
    end

    def run_touch_callbacks
      run_callbacks(:touch)
    end

    # there's a weird quirk with the delegate stuff that does not automatically save the delegate object
    # when saving so we force a save using a hook
    def save_master
      begin
        if master && (master.changed? || master.new_record?)
          master.branch_id = self.branch_id
          master.shop_id = self.shop_id
          master.save!
          @nested_changes = true
        end
      # If the master cannot be saved, the Product object will get its errors and will be destroyed
      rescue ActiveRecord::RecordInvalid
        master.errors.each do |att, error|
          self.errors.add(att, error)
        end
        raise
      end
    end

    # 如果产品同属子分类和父分类，应只保存在子分类下
    def check_category_parent(category)
      if self.categories.include?(category.parent)
        self.categories.delete category.parent
      end
      match_subs = self.categories & category.subs
      self.categories.delete(category) if match_subs.present?
    end

    def reset_name_abbr
      self.name_abbr = PinYin.abbr(self.name)
    end

    def touch_categories(product = nil)
      self.categories.update_all(updated_at: Time.now)
    end

  end
end
