module Ddt
  module Backend
    module Branch
      class EventPromotionsController < ::Ddt::Backend::BaseController
        include Backend::BasePromotionsController
        check_permission :branch, :event_promotion
        layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }
      end
    end
  end
end