FactoryGirl.define do
  factory :delivery_zone, class: Ddt::DeliveryZone do
    shop_id 1
    branch_id 1
    zone_name "zone_name"
    cost 5.00
  end
end
