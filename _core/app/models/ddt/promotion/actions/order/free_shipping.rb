module Ddt
  class Promotion
    module Actions
      module Order
        class FreeShipping < Ddt::PromotionAction
          include Ddt::PromotionActionModelName
          def perform(promotable)
            promotable.try(:free_shipment)
          end
        end
      end
    end
  end
end