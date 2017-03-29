module Ddt
  class ProductTag < Ddt::Tag
    has_many :products_tags, class_name: 'Ddt::ProductsTag', foreign_key: :tag_id, dependent: :destroy
    has_many :products, through: :products_tags, class_name: 'Ddt::Product'
  end
end
