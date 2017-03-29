module Ddt
  module Backend
    module Branch
      module EventPromotion
        class PromotionRulesController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionRulesController
          check_permission :branch, :event_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end