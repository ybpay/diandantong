require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class DeliveryTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:itemable){ variant }
        let(:address){ create :address, base_user: user }
        let(:shipment){ Ddt::Shipment.new(branch: branch, shop: shop, address: address)}
        let(:cart){ OrderService::Cart::Delivery.new(branch: branch, shipment: shipment) }
        let(:cart_with_pay_method){ OrderService::Cart::Delivery.new(branch: branch, pay_method: :pay_on_arrive) }
        let(:cart_class){ OrderService::Cart::Delivery }

        def test_free_shipment
          cart.free_shipment
          assert_equal 0, cart.shipment_total
        end

        def test_initialize_with_shipment
          cart = OrderService::Cart::Delivery.new(branch: branch, shipment: shipment)
          assert_equal cart.delivery_name, address.name
        end

        concerning :IsTodayDelivery do
          def test_is_today_delivery_with_nil
            assert cart.is_today_delivery?
          end

          def test_is_today_delivery_with_today
            assert cart.is_today_delivery?(Date.today)
          end

          def test_is_today_delivery_with_today_string
            assert cart.is_today_delivery?(Date.today.strftime("%F"))
          end
        end

        concerning :Place do
          def test_shipment_save
            cart.add(itemable)
            order = cart.place
            assert order.shipment.present?
          end
        end

        def test_extra_amount
          assert_equal cart.shipment_total, cart.extra_amount
        end

        concerning :SessionStore do
          def test_to_session
            session = cart.to_session
            assert session[:shipment_address_id].present?
          end

          def test_cart_options_from_session
            options = cart_class.cart_options_from_session(cart.to_session)
            assert options[:shipment].present?
          end
        end

        def test_update_shipment
          skip # todo
        end

        def test_ensure_essential_products
          cart = OrderService::Cart::Delivery.new(branch: branch, track_from: :FromWechat)
          branch.essential_products.delivery.create(variant: variant, quantity: 1)
          cart.ensure_essential_products
          assert_equal cart.line_items.count, 1
        end

        concerning :Validation do
          def test_check_essential_products
            cart = OrderService::Cart::Delivery.new(branch: branch, track_from: :FromWechat)
            branch.essential_products.delivery.create(variant: variant, quantity: 1)
            cart.send(:check_essential_products)
            assert cart.errors.present?
          end
        end
      end
    end
  end
end