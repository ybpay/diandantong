FactoryGirl.define do
  factory :product, class: Ddt::Product do
    name
    shop_id 1
    branch_id 1
    description "description"
    unit_name "份"
    availabled_at { 1.hour.ago }
    categories { [create(:category)] }
    min_quantity_for_order 1
    price 10.00
    vip_price 9.00
    sku
    factory :product_with_variants, class: Ddt::Product do
      transient do
        variants_count 2
      end
      after :create do |product, evaluator|
        option_type = create :option_type_with_option_values, option_values_count: evaluator.variants_count
        product.option_types << option_type
        option_type.option_values.each do |option_value|
          create :variant, product: product, branch_id: product.branch_id, option_values: [option_value]
        end
      end
    end
  end
end
