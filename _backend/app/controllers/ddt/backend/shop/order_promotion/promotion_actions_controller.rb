module Ddt
  module Backend
    module Shop
      module OrderPromotion
        class PromotionActionsController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionActionsController
          check_permission :shop, :order_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end