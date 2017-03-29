module Ddt
  module Backend
    module Shop
      class EventPromotionsController < ::Ddt::Backend::BaseController
        include Backend::BasePromotionsController
        check_permission :shop, :event_promotion
      end
    end
  end
end