require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class EatInHallTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::EatInHall.new(branch: branch, table: table) }
        let(:cart_with_pay_method){ OrderService::Cart::EatInHall.new(branch: branch, table: table, pay_method: :pay_on_face) }
        let(:cart_class){ OrderService::Cart::EatInHall }

        def test_initialize_with_table
          table.guest_num = 2
          cart = OrderService::Cart::EatInHall.new(branch: branch, table: table)
          assert_equal 2, cart.guest_num
        end

        def test_ensure_essential_products
          cart = OrderService::Cart::EatInHall.new(branch: branch, table: table, track_from: :FromWechat)
          branch.essential_products.eat_in_hall.create(variant: variant, per_guest: false, quantity: 1)
          cart.ensure_essential_products
          assert_equal cart.line_items.count, 1
        end

        def test_ensure_essential_products_with_per_guest
          cart = OrderService::Cart::EatInHall.new(branch: branch, table: table, track_from: :FromWechat, guest_num: 2)
          branch.essential_products.eat_in_hall.create(variant: variant, per_guest: true, quantity: 1)
          cart.ensure_essential_products
          assert_equal cart.line_items.first.quantity, 2
        end

        concerning :Validation do
          def test_check_essential_products
            cart = OrderService::Cart::EatInHall.new(branch: branch, table: table, track_from: :FromWechat)
            branch.essential_products.eat_in_hall.create(variant: variant, per_guest: false, quantity: 1)
            cart.send(:check_essential_products)
            assert cart.errors.present?
          end
        end

        concerning :SessionStore do
          def test_to_session
            session = cart.to_session
            assert session[:table_id].present?
          end

          def test_cart_options_from_session
            options = cart_class.cart_options_from_session(cart.to_session)
            assert options[:table].present?
          end
        end

        def test_update_table_info
          table.guest_num = 1
          cart = OrderService::Cart::EatInHall.new(branch: branch, table: table, track_from: :FromWechat)
          cart.update_table_info(table_id: another_table.id, guest_num: 2)
          assert_equal 2, cart.guest_num
          assert_equal another_table.id, cart.table_id
          assert_equal another_table.name, cart.table_name
        end

        concerning :MergeOrderItemable do
          def test_set_order_itemables_from_table
            cart.add(itemable)
            cart.user = user
            assert_change "OrderItemable.count" do
              Ddt::OrderItemable::Adapter.new(store_type: 'for_merge_order', table_id: cart.table.id).update_from_cart(cart)
            end
            cart.set_order_itemables_from_table(table)
            assert_equal cart.line_items.count, 1
          end
        end
      end
    end
  end
end
