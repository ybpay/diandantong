require "test_helper"
module Ddt
  class VariantTest < TestCase::Base
    include ItemableTest
    let(:variant){ create(:product, branch_id: branch.id).master }
    let(:variants){ create(:product_with_variants, branch_id: branch.id).variants}
    let(:variant_with_option_value){ create(:product_with_variants, branch_id: branch.id).variants.first }
    let(:another_variant_with_option_value){ create(:product_with_variants, branch_id: branch.id).variants.last }
    let(:itemable){ variant }


    setup do
    end

    concerning :EstimateClear do

      def test_remove_estimate_clear_when_stock_quantity_change_from_zero_0
        variant.update(stock_quantity: 0, estimate_clear: true, estimate_clear_reciprocal: false)
        variant.update(stock_quantity: 2)
        assert !variant.estimate_clear?
      end

      def test_remove_estimate_clear_when_stock_quantity_change_from_zero_1
        variant.update(stock_quantity: 0, estimate_clear: false, estimate_clear_reciprocal: false)
        variant.update(stock_quantity: 2)
        assert !variant.estimate_clear?
      end

      def test_remove_estimate_clear_when_stock_quantity_change_from_non_zero
        variant.update(stock_quantity: 1, estimate_clear: true, estimate_clear_reciprocal: false)
        variant.update(stock_quantity: 2)
        assert variant.estimate_clear?
      end

      def test_estimate_clear
        variant.add_estimate_clear
        assert variant.estimate_clear?
        assert variant.product.estimate_clear?
      end

      def test_remove_estimate_clear
        variant.add_estimate_clear
        variant.remove_estimate_clear
        assert !variant.estimate_clear?
        assert !variant.product.estimate_clear?
        assert_equal Ddt::Variant::MAX_STOCK_QUANTITY, variant.stock_quantity
      end

      def test_estimate_clear_variants
        count = variants.size
        variants.each_with_index do |variant, index|
          variant.add_estimate_clear
          if index + 1 < count
            assert variant.estimate_clear?
            assert !product.estimate_clear?
          end
        end
        assert variants.first.product.estimate_clear?
      end

      def test_remove_estimate_clear_variants
        test_estimate_clear_variants
        variants.first.remove_estimate_clear
        assert !variants.first.product.estimate_clear?
      end

      def test_add_estimate_clear_reciprocal
        variant.add_estimate_clear_reciprocal(quantity: 2)
        assert variant.estimate_clear_reciprocal?
        assert_equal 2, variant.stock_quantity
      end

      def test_remove_estimate_clear_reciprocal
        variant.add_estimate_clear_reciprocal(quantity: 2)
        variant.remove_estimate_clear_reciprocal
        assert !variant.estimate_clear_reciprocal?
        assert_equal Ddt::Variant::MAX_STOCK_QUANTITY, variant.stock_quantity
      end
    end

  end
end
