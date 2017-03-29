module Ddt
  module OrderService
    module Order
      module Concern
        module UpdaterTest
          extend ActiveSupport::Concern
          def test_update_total_base
            order.update_total
            assert_equal false, order.changed?
          end

          def test_update_total_with_update_promotion
            order
            order_promotion
            order.stubs(:evaluate_promotion?).returns(true)
            order.line_items.stubs(:changed?).returns(true)
            assert_change %W[order.promotions.count order.adjustments.promotion.count] do
              order.update_total
            end
          end

          def test_update_total_with_update_pay_item
            order.load_pay_item(OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop))
            order.stubs(:get_amount_for_pay).returns(1)
            assert_change %W[order.pay_item_total order.pay_items.first.amount] do
              order.update_total
            end
          end

          def test_update_pay_info
            skip
          end
        end
      end
    end
  end
end