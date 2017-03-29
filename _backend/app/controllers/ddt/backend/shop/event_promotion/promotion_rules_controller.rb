module Ddt
  module Backend
    module Shop
      module EventPromotion
        class PromotionRulesController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionRulesController
          check_permission :shop, :event_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end