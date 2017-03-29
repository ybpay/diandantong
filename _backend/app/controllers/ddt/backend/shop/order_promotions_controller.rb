module Ddt
  module Backend
    module Shop
      class OrderPromotionsController < ::Ddt::Backend::BaseController
        include Backend::BasePromotionsController
        check_permission :shop, :order_promotion
      end
    end
  end
end