FactoryGirl.define do
  factory :vip_info, class: Ddt::VipInfo do
    shop_id 1
    vip_no
    vip_level_id 1
    builtin true
    name
    phone
    created_at Time.now
  end
end
