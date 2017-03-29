module Ddt
  module OrderService
    module Order
      module Concern
        module StockSaleTest
          extend ActiveSupport::Concern

          def test_update_stock_quantity_with_variant
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(variant)
            line_item.stubs(:itemable_type).returns("Ddt::Variant")
            line_item.stubs(:itemable_id).returns(variant.id)
            assert_change "variant.reload.stock_quantity" do
              order.update_stock_quantity
            end
          end


          def test_estimate_clear_reciprocal_enable
            branch.update!(check_stock: false)
            variant.update!(estimate_clear_reciprocal: true, branch: branch)
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(variant)
            line_item.stubs(:itemable_type).returns("Ddt::Variant")
            line_item.stubs(:itemable_id).returns(variant.id)
            assert_change "variant.reload.stock_quantity" do
              order.update_stock_quantity
            end
          end

          def test_estimate_clear_reciprocal_disable
            branch.update!(check_stock: false)
            variant.update!(estimate_clear_reciprocal: false, branch: branch)
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(variant)
            line_item.stubs(:itemable_type).returns("Ddt::Variant")
            line_item.stubs(:itemable_id).returns(variant.id)
            assert_no_change "variant.reload.stock_quantity" do
              order.update_stock_quantity
            end
          end

          def test_update_stock_quantity_with_combo_package
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(combo_package)
            line_item.stubs(:itemable_type).returns("Ddt::ComboPackage")
            variant = combo_package.combo_package_items.first.variant
            assert_change ["variant.reload.stock_quantity", "combo_package.combo.reload.stock_quantity"] do
              order.update_stock_quantity
            end
          end

          def test_update_sale_quantity_with_variant
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(variant)
            line_item.stubs(:itemable_type).returns("Ddt::Variant")
            line_item.stubs(:itemable_id).returns(variant.id)
            assert_change "variant.reload.sale_quantity" do
              order.update_sale_quantity
            end
          end

          def test_update_sale_quantity_with_combo_package
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(combo_package)
            line_item.stubs(:itemable_type).returns("Ddt::ComboPackage")
            variant = combo_package.combo_package_items.first.variant
            assert_change ["variant.reload.sale_quantity", "combo_package.combo.reload.sale_quantity"] do
              order.update_sale_quantity
            end
          end

          def test_rollback_stock_quantity_with_variant
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(variant)
            line_item.stubs(:itemable_type).returns("Ddt::Variant")
            line_item.stubs(:itemable_id).returns(variant.id)
            assert_change "variant.reload.stock_quantity" do
              order.rollback_stock_quantity
            end
          end

          def test_rollback_stock_quantity_with_combo_package
            line_item = order.line_items.first
            line_item.stubs(:itemable).returns(combo_package)
            line_item.stubs(:itemable_type).returns("Ddt::ComboPackage")
            variant = combo_package.combo_package_items.first.variant
            assert_change ["variant.reload.stock_quantity", "combo_package.combo.reload.stock_quantity"] do
              order.rollback_stock_quantity
            end
          end

          private
          def combo_package
            @combo_package ||= create(:combo_with_package, branch_id: branch.id).combo_packages.first
          end
        end
      end
    end
  end
end
