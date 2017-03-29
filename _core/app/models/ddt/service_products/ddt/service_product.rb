# encoding: utf-8

# 服务套餐的基类，实现新的虚拟物品时从该类继承，使用preference声明需要的参数，然后实现perform方法。
# 最后将类名添加到PRODUCT_TYPES数组中，同时在zh-CN.yml文件中添加模型的翻译。。
module Ddt
  class ServiceProduct < Ddt::Base
    acts_as_list

    PRODUCT_TYPES = ["Ddt::ShortMessageRecharge", "Ddt::PrinterToken"]

    ### relationships
    has_many :service_product_orders, class_name: 'Ddt::ServiceProductOrder'

    ### validations
    validates :subject, presence: true
    validates :type, presence: true
    validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
    validates :description, presence: true

    ### scopes
    default_scope { order("position ASC") }

    acts_as_type :type, PRODUCT_TYPES, PRODUCT_TYPES.map { |type| I18n.t("activerecord.models.#{type.underscore}") }

    # 订单完成后执行的动作
    def perform(shop)
      raise 'perform should be implemented in a sub-class of Ddt::ServiceProduct'
    end

    # 根据类名查找默认的preferences
    def self.default_preferences_for(class_name)
      if PRODUCT_TYPES.map(&:to_s).include?(class_name)
        class_name.constantize.new.default_preferences
      else
        raise "#{class_name} is not a subclass of Ddt::ServiceProduct"
      end
    end

    def set_preferences_converted(prefs)
      if prefs.present?
        prefs.each do |key, value|
          self.send("preferred_#{key}=", value)
        end
      end
    end

  end
end
