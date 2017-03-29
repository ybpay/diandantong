# encoding:utf-8
module Ddt
  class ProductOptionType < Ddt::Base
    include Ddt::BelongsToBranch
    replicated_model

    belongs_to :product, class_name: 'Ddt::Product'
    belongs_to :option_type, class_name: 'Ddt::OptionType'
    acts_as_list scope: [:product_id]
    set_shop_and_branch_from :product
  end
end