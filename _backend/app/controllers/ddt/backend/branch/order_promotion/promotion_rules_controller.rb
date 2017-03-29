module Ddt
  module Backend
    module Branch
      module OrderPromotion
        class PromotionRulesController < ::Ddt::Backend::BaseController
          include Backend::BasePromotionRulesController
          check_permission :branch, :order_promotion, {index: :show, [:create, :destroy] => :update}
        end
      end
    end
  end
end