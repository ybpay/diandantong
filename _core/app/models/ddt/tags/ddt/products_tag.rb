module Ddt
  class ProductsTag < Ddt::Base
    belongs_to :product, class_name: 'Ddt::Product', touch: true
    belongs_to :tag, class_name: 'Ddt::ProductTag',counter_cache: :count
  end
end
