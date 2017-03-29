module Ddt
  module Backend
    module Shop
      module OrderPromotion
        class PromotionRulesController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionRulesController
          check_permission :shop, :order_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end