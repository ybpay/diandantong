FactoryGirl.define do
  factory :user, class: Ddt::User do
    shop { create :shop }
    unique_user
    created_at { Time.now }
    after :create do |user|
      create(:wechat_user, shop_id: user.shop_id, user_open_id: user.unique_user.user_open_id)
    end
  end

  factory :phone_user, class: Ddt::PhoneUser do
    shop  { create :shop }
    phone
    factory :phone_user_with_address, class: Ddt::PhoneUser do
      after :create do |phone_user|
        phone_user.addresses.create(name: "name", content: "content", phone: generate(:phone))
      end
    end
  end
end
