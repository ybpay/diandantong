module Ddt
  class Promotion
    module Rules
      module Event
        class UserSignRecordsCount < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          preference :count, :integer , default: 10


          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::UserSignIn)
          end

          def eligible?(promotable)
            promotable.user.sign_records_count % self.preferred_count == 0
          end

        end
      end
    end
  end
end