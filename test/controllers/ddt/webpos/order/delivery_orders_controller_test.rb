require "test_helper"
require_relative "base_order_controller_test"
require_relative "base_order_change_controller_test"
module Ddt
  module Webpos
    module Order
      class DeliveryOrdersControllerTest < TestCase::Controller::Webpos
        include Ddt::Webpos::Order::BaseOrderControllerTest
        include Ddt::Webpos::Order::BaseOrderChangeControllerTest
        setup do
          sign_in worker
          @order = example_delivery_order
        end

        def test_create
          assert_difference "branch.delivery_orders.count" do
            post :create, p(
              order: {
                form_content_attributes: [
                  { form_element_id: form_element_text.id, content: "content"},
                  { form_element_id: form_element_select.id, type: :quote, content: form_element_select.form_elements.first.id }
                ]
              },
              cart: {
                line_items_attributes: [{
                itemable_type: "Ddt::Variant",
                itemable_id: variant.id,
                quantity: 1
              }]}, user: {
                phone: "13812345678",
                name: "name",
                address: "address",
                delivery_zone_id: delivery_zone.id,
                delivery_date: Date.today.strftime("%F")
              })
          end
          assert_response 200
        end
      end
    end
  end
end