module Ddt
  module Backend
    module Shop
      module EventPromotion
        class PromotionActionsController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionActionsController
          check_permission :shop, :event_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end