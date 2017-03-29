module Ddt
  module Backend
    module Branch
      module EventPromotion
        class PromotionActionsController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionActionsController
          check_permission :branch, :event_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end