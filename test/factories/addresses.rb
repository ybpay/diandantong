FactoryGirl.define do
  factory :address, class: Ddt::Address do
    base_user { create(:phone_user) }
    name
    phone
    content "content"
  end
end
