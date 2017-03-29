# encoding:utf-8
module Ddt
  class Deduction < Ddt::Base
    include BelongsToShop
    include Frozenable
    belongs_to_order
    set_shop_from :order
  end
end