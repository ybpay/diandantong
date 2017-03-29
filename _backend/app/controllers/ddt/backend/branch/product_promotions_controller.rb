module Ddt
  module Backend
    module Branch
      class ProductPromotionsController < ::Ddt::Backend::BaseController
        include Backend::BasePromotionsController
        check_permission :branch, :order_promotion
        layout lambda { params[:layout_name]||'ddt/layouts/backend/promotion' }
      end
    end
  end
end