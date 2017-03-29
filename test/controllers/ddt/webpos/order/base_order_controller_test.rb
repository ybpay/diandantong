require "test_helper"
module Ddt
  module Webpos
    module Order
      module BaseOrderControllerTest
        extend ActiveSupport::Concern
        included do
          def test_show
            get :show, p( id: @order.id )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_cancel
            post :cancel, p( id: @order.id, cancel_reason: "cancel_reason" )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_confirm
            post :confirm, p( id: @order.id )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_complete
            @order.confirm
            set_order_paid
            post :complete, p( id: @order.id )
            assert_response 200
            assert_equal json["id"], @order.id
          end

          def test_change_vip_info
            post :change_vip_info, p(id: @order.id, vip_info_id: vip_user.vip_info_id)
            assert_response 200
          end

          def test_unbind_vip_info
            @order.change_vip_info(vip_user.vip_info)
            post :unbind_vip_info, p(id: @order.id)
            assert_response 200
          end

          def test_credits_deduction
            skip # TODO
          end

          def test_card_deduction
            skip # TODO
          end

          def test_privilege_discount
            skip # TODO
          end

          def test_privilege_reduction
            skip # TODO
          end

          def test_moling
            skip # TODO
          end

          def test_cancel_privilege_discount
            skip # TODO
          end

          def test_cancel_privilege_reduction
            skip # TODO
          end

          def test_cancel_privilege_free
            skip # TODO
          end

          def test_cancel_moling
            skip # TODO
          end

          def test_apply_coupon
            skip # TODO
          end

          def test_rollback_coupon
            skip # TODO
          end

          def test_apply_voucher
            skip # TODO
          end

          def test_rollback_voucher
            skip # TODO
          end

          def test_bill
            skip # TODO
          end

          def test_create_pay_items
            post :create_pay_items, p(id: @order.id, pay_items: [{
                name_sym: "pay_on_face",
                amount: @order.total
              }], is_local_printed: false)
            assert_response 200
            assert_equal json["pay_items"].size, 1
          end

          def test_clear_pay_items
            pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: @order.total, shop: shop)
            @order.create_pay_items([pay_itemable])
            post :clear_pay_items, p(id: @order.id)
            assert_response 200
            assert_equal json["pay_items"].size, 0
          end

          def test_pay_all_pay_items
            pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: @order.total, shop: shop)
            @order.create_pay_items([pay_itemable])
            post :pay_all_pay_items, p(id: @order.id)
            assert_response 200
            assert_equal json["pay_item_state"], "paid"
          end

          private
          def set_order_paid(account=nil)
            @order.operator = account
            pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: @order.total, shop: shop)
            pay_item = @order.load_pay_item(pay_itemable)
            @order.change_pay_item_to_paid(pay_item)
          end
        end
      end
    end
  end
end