FactoryGirl.define do
  factory :shop, class: Ddt::Shop do
    slug
    telephone
    expiration_time { 7.days.since }
    address "address"
    track_from "FromBackend"
    shop_type "o3"
    max_branches_limit 5
    factory :shop_with_boss, class: Ddt::Shop do
      after(:create){ |shop|
        create(:boss, shop: shop, login_id: shop.slug, built_in: true)
      }
    end
  end
end
