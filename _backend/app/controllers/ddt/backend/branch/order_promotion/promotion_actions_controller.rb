module Ddt
  module Backend
    module Branch
      module OrderPromotion
        class PromotionActionsController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionActionsController
          check_permission :branch, :order_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end