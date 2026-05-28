# encoding:utf-8
module Ddt
  class OptionType < Ddt::Base
    include Discard::Model
    default_scope { kept }
    include Ddt::BelongsToBranch
    include Ddt::ListScope

    # reladtions
    has_many :product_option_types, dependent: :destroy, class_name: 'Ddt::ProductOptionType'
    has_many :products, through: :product_option_types, class_name: 'Ddt::Product'
    has_many :option_values, dependent: :destroy, inverse_of: :option_type, class_name: 'Ddt::OptionValue'
    accepts_nested_attributes_for :option_values, reject_if: lambda { |ov| ov[:name].blank? }, allow_destroy: true

    # validations
    validates_presence_of :name

    # scopes
    acts_as_list scope: [:branch, :deleted_at]
    default_scope -> { order(position: :asc) }

    # callbacks
    after_touch :touch_all_products

    def touch_all_products
      products.find_each(&:touch)
    end

  end
end