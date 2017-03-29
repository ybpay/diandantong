FactoryGirl.define do
  factory :branch, class: Ddt::Branch do
    name
    phone
    address "address"
    product_list_style "thumb"
    charge_method ""
    latitude 31.236305
    longitude 121.480237
    parking_space_count 0
    promotion_in_webpos true
    shop
    branch_type
  end
end
