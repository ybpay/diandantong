module Ddt
  module OrderService
    module Order
      module Concern
        module DeductionTest
          extend ActiveSupport::Concern
          def test_add_card_deduction
            order.change_vip_info(vip_user.vip_info)
            assert_change ["order.total", "order.adjustments.card_deduction.count"] do
              order.add_card_deduction(1)
            end
          end

          def test_add_card_deduction_with_not_enough_amount
            order.change_vip_info(user.vip_info)
            assert_no_change ["order.total", "order.adjustments.card_deduction.count"] do
              order.add_card_deduction(1)
            end
            assert order.errors.present?
          end

          def test_add_credits_deduction
            order.change_vip_info(vip_user.vip_info)
            assert_change ["order.total", "order.adjustments.credits_deduction.count"] do
              order.add_credits_deduction(1)
            end
          end

          def test_add_credits_deduction_with_not_enough_amount
            order.change_vip_info(user.vip_info)
            assert_no_change ["order.total", "order.adjustments.credits_deduction.count"] do
              order.add_credits_deduction(1)
            end
            assert order.errors.present?
          end
        end
      end
    end
  end
end
