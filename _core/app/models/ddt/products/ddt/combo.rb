#encoding:utf-8
module Ddt
  class Combo < Ddt::Base
    include Ddt::SoftDeletable

    include Ddt::ListScope
    include Ddt::Productable
    include Ddt::BelongsToBranchWithTouch


    # relations
    has_many :combo_items, dependent: :destroy, class_name: 'Ddt::ComboItem', inverse_of: :combo
    has_many :combo_packages, class_name: 'Ddt::ComboPackage'
    has_many :combos_combo_images, class_name: 'Ddt::CombosComboImage', dependent: :destroy
    has_many :images, class_name: 'Ddt::ComboImage', through: :combos_combo_images, source: :combo_image

    # validations
    validates_uniqueness_of :sku, allow_blank: true, scope: [:branch_id], conditions: -> { where(deleted_at: nil) }
    validates :stock_quantity, numericality: { greater_than_or_equal_to: 0, less_than: MAX_INTEGER }
    validates :availabled_at, presence: true

    # scope
    scope :available, ->(){ where("ddt_combos.availabled_at < ? && (ddt_combos.end_at is null or ddt_combos.end_at > ?)", Time.now, Time.now)}
    acts_as_list scope: [:branch, :deleted_at]
    scope :on_shelf, ->() { where(on_shelf: true) }
    default_scope ->{ list_order }

    scope :of_wechat, -> () {where(show_on_wechat: true)}

    #callback
    after_save :assign_sku
    touch_cache_version_of_scope :branch

    # methods
    def config_ok?
      combo_items.size > 0
    end

    def assign_sku
      self.update_columns(sku: self.id) if self.sku.blank?
    end

    def fixed_part_price
      combo_items.fixed_price.sum(:price)
    end

    def fixed_part_vip_price
      combo_items.fixed_price.sum(:vip_price)
    end

    def add_combo_package(items=[], allow_lacking: false)
      # items: [{ combo_item_id, variant_id, quantity }]
      if items.nil?
        self.errors[:base] << "菜品未选"
        return false
      end
      transaction do
        combo_package = self.combo_packages.create
        items.each do |item|
          variant = Ddt::Variant.find(item[:variant_id])
          if variant.stock_quantity >= item[:quantity].try(:to_i)
            combo_package.combo_package_items.create!(
              combo_item_id: item[:combo_item_id],
              variant_id: item[:variant_id],
              quantity: item[:quantity],
              combo_id: self.id,
              sku: variant.sku,
              ) if self.errors.blank?
          else
            self.errors[:base] << "#{variant.cache_name}库存不足"
          end
        end
        if self.errors.present?
          raise ActiveRecord::Rollback
          false
        end
        if combo_package.quantity_right?(allow_lacking)
          combo_package.cache_name
          Ddt::ComboPackageItem.set_prices(combo_package.combo_package_items)
          combo_package
        else
          self.errors[:base] << "套餐数量不正确"
          raise ActiveRecord::Rollback
          false
        end
      end
    end

    def self.set_on_shelf(ids)
      where(id: ids).update_all(on_shelf: true, updated_at: Time.now)
    end

    def self.set_off_shelf(ids)
      where(id: ids).update_all(on_shelf: false, updated_at: Time.now)
    end

    def select_json
      { id: id, name: name}
    end

    def avatar
      nil
    end

    def avatar_url
      nil
    end

    def disable_discount?
      !enable_discount?
    end

  end
end
