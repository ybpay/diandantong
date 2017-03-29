module Ddt
  module ItemableTest
    def test_itemable
      [
        :name,
        :sku,
        :product_name,
        :itemable_name,
        :original_price,
        :price,
        :vip_price,
        :stock_quantity,
        :unit_name,
        :avatar_url,
        :min_quantity_for_order,
        :stock_enough?,
        :enable_discount,
        :enable_change_price,
        :itemable_type,
        :itemable_id,
        :to_line_itemable,
        :category_ids,
        :category_names,
      ].each do |method_name|
        itemable.send(method_name)
        assert_respond_to itemable, method_name
      end
    end
  end
end
