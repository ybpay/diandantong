require "test_helper"
require_relative "base_cart_controller_test"
require_relative "base_cart_coupon_controller_test"
module Ddt
  module Weixin
    module Cart
      class EatInHallCartsControllerTest < TestCase::Controller::Weixin
        include Weixin::Cart::BaseCartControllerTest
        include Weixin::Cart::BaseCartCouponControllerTest
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::EatInHall.new(branch: branch, table: table, user: user)}
        setup do
          # scan_qrcode
          Ddt::OrderItemable::Adapter.new(store_type: 'for_merge_order', table_id: table.id).attach(session)
        end

        def test_update_table_info
          post :update_table_info, p(cart: { table_id: table.id, guest_num: 2 })
          assert_response 200
          assert_equal table.id, json["table_id"]
          assert_equal 2, json["guest_num"]
        end

        def test_set_order_itemables_from_table
          cart.add(itemable)
          Ddt::OrderItemable::Adapter.get_from(session).update_from_cart(cart)
          set_cart_session(cart)
          post :set_order_itemables_from_table, p(table_id: table.id)
          assert_response 200
          assert_equal 1, json["line_items"].size
        end
      end
    end
  end
end
