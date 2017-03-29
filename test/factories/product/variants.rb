FactoryGirl.define do
  factory :variant, class: Ddt::Variant do
    shop_id 1
    branch_id 1
    is_master false
    product
    price     10.00
    vip_price 10.00
  end
end
