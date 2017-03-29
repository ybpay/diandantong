FactoryGirl.define do
  factory :vip_level, class: Ddt::VipLevel do
    name
    discount 0.9
  end
end
