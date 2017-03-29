require "test_helper"
module Ddt
  module OrderService
    class LineItemTest < TestCase::Base
      concerning :ChangedValues do
        included do
          let(:order) { stub(shop: shop, is_vip?: false) }
        end

        def test_changed_values_with_line_item_trace_points_of_variant
          line_item = OrderService::LineItem.new(itemable: variant, quantity: 1, order: order)
          assert line_item.changed_values[:line_item_trace_points].present?
        end

        def test_changed_values_with_line_item_trace_points_of_combo
          combo_package = create(:combo_with_package).combo_packages.first
          line_item = OrderService::LineItem.new(itemable: combo_package, quantity: 1, order: order)
          assert line_item.changed_values[:line_item_trace_points].present?
        end

        def test_changed_values_without_line_item_trace_points_if_subtract
          line_item = OrderService::LineItem.new(itemable: variant, quantity: -1, is_subtract: true, order: order)
          assert line_item.changed_values[:line_item_trace_points].blank?
        end

        def test_changed_values_without_line_item_trace_points_if_exists
          line_item = OrderService::LineItem.new(itemable: variant, quantity: 1, id: 1, order: order)
          assert line_item.changed_values[:line_item_trace_points].blank?
        end
      end
    end
  end
end