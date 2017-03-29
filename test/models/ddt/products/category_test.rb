require "test_helper"
module Ddt
  class CategoryTest < TestCase::Base
    let(:category){ create(:category_with_subs, subs_count: 1) }
    let(:sub){ category.subs[0] }

    def test_name_with_parent
      assert_equal category.name_with_parent, "#{category.name}"
      assert_equal sub.name_with_parent, "#{category.name}-#{sub.name}"
    end

    def test_depth
      assert_equal 1, category.depth
      assert_equal 2, sub.depth
    end

    def test_subs_with_self
      assert_equal category.subs_with_self, [category, sub]
      assert_equal sub.subs_with_self, [sub]
    end

    concerning :ClassMethod do
      def test_with_subs
        assert_equal Ddt::Category.where(id: category.id).with_subs, [category, sub]
        assert_equal Ddt::Category.where(id: sub.id).with_subs, [sub]
      end

      def test_with_sub_ids
        assert_equal Ddt::Category.where(id: category.id).with_sub_ids, [category.id, sub.id]
        assert_equal Ddt::Category.where(id: sub.id).with_sub_ids, [sub.id]
      end

      def test_get_product_ids
        product = create(:product)
        sub.products << product
        assert_equal Ddt::Category.get_product_ids([sub.id]), [product.id]
      end

      def test_get_product_ids_with_empty_array
        assert_equal Ddt::Category.get_product_ids([]), []
      end

      def test_product_ids
        product = create(:product)
        category.products << product
        assert_equal Ddt::Category.where(id: category.id).product_ids, [product.id]
      end

      def test_product_ids_with_sub
        product1 = create(:product)
        product2 = create(:product)
        category.products << product1
        sub.products << product2
        assert_equal Ddt::Category.where(id: category.id).product_ids_with_sub, [product1.id, product2.id]
      end
    end

    concerning :UpdateProducts do
      def test_update_products
        product = create(:product, enable_discount: true)
        category.products << product
        Ddt::Category.where(id: category.id).update_products(enable_discount: false)
        assert_equal product.reload.enable_discount, false
      end
    end

  end
end