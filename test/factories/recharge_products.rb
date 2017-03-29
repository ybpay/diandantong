FactoryGirl.define do
  factory :recharge_product, class: Ddt::RechargeProduct do
    shop_id 1
    name
    price 100
    recharge_amount 120
    extra_credits 10
    first_recharge_available_amount 100
  end
end
