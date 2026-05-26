# encoding: utf-8
module Ddt
  class WechatMenu < Ddt::Base
    include ActsAsType
    include ListScope

    auto_strip_attributes :url
    filter_urls_for :url

    acts_as_type :menu_type, [:button], %W[按钮]
    acts_as_type :event_type, [:click, :view, :scancode_push], %W[微信回复 链接跳转 扫码]



    include BelongsToShop
    acts_as_list scope: [:shop_id, :parent_id]
    belongs_to :wechat_account, class_name: 'Ddt::WechatAccount'
    belongs_to :parent, class_name: "Ddt::WechatMenu", foreign_key: 'parent_id', counter_cache: :subs_count
    has_many :subs, ->{ list_order }, class_name: "Ddt::WechatMenu", foreign_key: 'parent_id', counter_cache: :subs_count, dependent: :destroy
    belongs_to :material, class_name: 'Ddt::Material'

    validates :name, :event_type, :menu_type, presence: true
    validates :name, uniqueness:{ :scope => :wechat_account_id }
    validates :material, presence: true, if: :is_click_event?
    validate :check_menu_count
    validates :url, uri: true, length: { maximum: 255 }, if: :is_view?
    # 一级菜单最长为16个字节，二级菜单最长为40个字节
    validates_length_of :name, maximum: 40, tokenizer: ->(str) { str.each_byte.to_a }
    validates_length_of :name, maximum: 16, tokenizer: ->(str) { str.each_byte.to_a }, if: 'self.parent.nil?'

    scope :root_menus, ->{ where(parent_id: nil).list_order }

    attr_accessor :reply_type
    REPLY_TYPES = [
     ["系统消息", :system_keyword],
     ["素材", :material]
    ]

    def to_menu_hash
      if button_menu?
        if is_view?
          {type: 'view', name: self.name, url: self.url}
        elsif is_click?
          {type: 'click', name: self.name, key: key}
        elsif is_scancode_push?
          {type: 'scancode_push', name: self.name, key: self.name}
        end
      elsif folder_menu?
        {name: self.name, sub_button: self.subs.map(&:to_menu_hash)}
      end
    end

    def key
      self.material ? self.material_id : self.keyword
    end

    def siblings
      self.parent.present? ? self.parent.subs : self.wechat_account.wechat_menus.root_menus
    end

    def self.material_options(shop)
      Ddt::Material.valid_materials(shop.materials).map{|material| [material.material_name, material.id]}
    end

    def self.system_keyword_options(wechat_account)
      wechat_account.system_keywords
    end

    # 按钮型菜单，包括无子菜单的一级菜单和二级菜单
    def button_menu?
      (self.parent.nil? && self.subs.blank?) || self.parent.present?
    end

    # 折叠型菜单，即有子菜单的一级菜单
    def folder_menu?
      self.parent.nil? && self.subs.present?
    end

    private
    def is_click_event?
      event_type == 'click' and !keyword.present? and parent.present?
    end

    def check_menu_count
      if self.new_record?
        if self.parent.present?
           self.errors[:base] << "微信公众帐号最多允许每个一级菜单最多包含5个子菜单" if self.parent.subs.count >=5
        else
           self.errors[:base] << "微信公众帐号最多允许新建3个一级菜单" if self.wechat_account.wechat_menus.root_menus.count >= 3
        end
      end
    end

  end
end
