module Ddt
  class Promotion
    module Actions
      module Event
        class Base < Ddt::PromotionAction

          def perform(promotable)
            promotable.try(:action_performed)
          end

        end
      end
    end
  end
end
