# encoding:utf-8
module Ddt
  class Category < Ddt::Base
    include Discard::Model
    default_scope { kept }

    include Ddt::ListScope
    include Ddt::BelongsToBranch

    # relations
    has_and_belongs_to_many :products, ->{ uniq }, class_name: 'Ddt::Product', join_table: 'ddt_categories_products'
    has_many :subs, inverse_of: :parent, class_name: 'Ddt::Category', foreign_key: :parent_id, dependent: :destroy
    belongs_to :parent, class_name: 'Ddt::Category', foreign_key: :parent_id, touch: true

    # validations
    validates_presence_of :name

    # scopes
    scope :root, ->{ includes(:subs).where(:parent_id => nil) }
    acts_as_list scope: [:branch_id, :parent_id]
    scope :support_delivery,    ->(is_support=true){ where(support_delivery: is_support)}
    scope :support_reservation, ->(is_support=true){ where(support_reservation: is_support)}
    scope :support_eat_in_hall, ->(is_support=true){ where(support_eat_in_hall: is_support)}
    scope :show_on_wechat, -> { where(:show_on_wechat => true)}
    scope :by_support_type,     ->(support_type){
      case support_type.to_sym
      when :delivery    ; support_delivery    ;
      when :reservation ; support_reservation ;
      when :eat_in_hall ; support_eat_in_hall ;
      end if support_type.present?
    }
    default_scope ->{ order(position: :asc)}

    # callbacks
    set_shop_and_branch_from :parent
    validate :check_depth
    validate :check_parent
    before_destroy :check_products_empty
    touch_cache_version_of_scope :branch

    def enable_discount?
      products.all?{|p| p.enable_discount}
    end

    def name_with_parent
      self.parent ? "#{self.parent.name_with_parent}-#{self.name}" : self.name
    end

    def depth
      self.parent ? self.parent.depth + 1 : 1
    end

    def subs_with_self
      [self, self.subs.to_a].flatten
    end

    def self.with_subs
      self.includes(:subs).map{|c| [c, c.subs]}.flatten
    end

    def self.with_sub_ids
      self.includes(:subs).map{|c| [c.id, c.sub_ids]}.flatten
    end

    def self.get_product_ids(category_ids)
      if category_ids.present?
        ActiveRecord::Base.connection.execute("select product_id from ddt_categories_products where category_id in (#{category_ids.join(',')});").to_a.flatten.uniq
      else
        []
      end
    end

    def self.get_variant_ids(category_ids)
      if category_ids.present?
        sql = <<-SQL.strip_heredoc
          select v.id
          from ddt_variants v inner join ddt_categories_products cp on cp.product_id = v.product_id
          where cp.category_id in (#{category_ids.join(",")});
        SQL
        ActiveRecord::Base.connection.execute(sql).to_a.flatten.uniq
      else
        []
      end
    end

    def self.product_ids
      Ddt::Category.get_product_ids(self.all.pluck(:id))
    end

    def self.product_ids_with_sub
      Ddt::Category.get_product_ids(self.with_sub_ids)
    end

    def self.update_products(params={})
      Ddt::Product.where(id: self.product_ids_with_sub).update_all(params.merge(updated_at: Time.now))
    end

    def update_products(params={})
      pids = Ddt::Category.get_product_ids(self.subs_with_self.map(&:id))
      Ddt::Product.where(id: pids).update_all(params.merge(updated_at: Time.now))
    end

    def to_filter
      {
        label: self.name,
        value: self.id,
        collection: self.subs.map(&:to_filter)
      }
    end

    def select_json
      { id: self.id, name: self.name_with_parent }
    end

    def empty?
      self_empty = self.products.count == 0
      if self.subs.length > 0
        self_empty && self.subs.all(&:empty?)
      else
        self_empty
      end
    end


    private
    def check_depth
      self.errors[:base] << "分类层级最多为2层" if self.depth > 2
    end

    def check_parent
      if !self.new_record? && self.parent_id_changed?
        self.errors[:parent_id] << "分类层级最多为2层" if max_depth > 2
      end
    end

    def check_products_empty
      if !self.empty?
        self.errors[:base] << "该分类下存在菜品，无法删除" 
        return false
      end
    end

    def max_depth
      [self.depth, self.subs.map(&:max_depth)].flatten.max
    end


  end
end
