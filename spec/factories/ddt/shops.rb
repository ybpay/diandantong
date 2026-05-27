# frozen_string_literal: true

FactoryBot.define do
  factory :shop, class: 'Ddt::Shop' do
    sequence(:name) { |n| "测试餐厅#{n}" }
    sequence(:telephone) { |n| "1380000#{n.to_s.rjust(4, '0')}" }
    slug { SecureRandom.hex(3) }
    shop_type { 'base' }
    max_branches_limit { 1 }
    expiration_time { 1.year.from_now }
    address { '上海市浦东新区' }
    is_open { true }

    after(:create) do |shop|
      create(:branch, shop: shop) if shop.branches.real.empty?
      create(:short_message_setting, shop: shop) unless shop.short_message_setting
    end

    trait :with_boss do
      after(:create) do |shop|
        account = create(:account, shop: shop, built_in: true)
        role = Ddt::Role::Boss.create!(shop: shop, name: 'boss', builtin: true)
        account.roles << role
      end
    end

    factory :shop_with_boss, class: 'Ddt::Shop', parent: :shop do
      with_boss
    end

    trait :multi_branch do
      max_branches_limit { 10 }
      shop_type { 'multiple' }
    end

    trait :expired do
      expiration_time { 1.day.ago }
    end
  end

  factory :branch, class: 'Ddt::Branch' do
    sequence(:name) { |n| "测试门店#{n}" }
    association :shop
    is_real { true }
    position { 1 }
    is_open { true }
    latitude { 31.2304 }
    longitude { 121.4737 }
  end

  factory :account, class: 'Ddt::Account' do
    sequence(:login_id) { |n| "test_login_#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:phone) { |n| "1390000#{n.to_s.rjust(4, '0')}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { '测试用户' }
    association :shop
    captcha_valid { true }
    accept_term { true }

    after(:build) do |account|
      account.shop ||= create(:shop)
      account.login_id = "#{account.shop.slug}:#{account.login_id}" unless account.login_id.include?(':')
    end
  end

  factory :user, class: 'Ddt::User' do
    sequence(:phone) { |n| "1500000#{n.to_s.rjust(4, '0')}" }
    association :shop
  end

  factory :product, class: 'Ddt::Product' do
    sequence(:name) { |n| "测试菜品#{n}" }
    price { 25.0 }
    association :shop
    association :branch

    after(:create) do |product|
      create(:variant, product: product, price: product.price) if product.variants.empty?
    end
  end

  factory :variant, class: 'Ddt::Variant' do
    sequence(:name) { |n| "规格#{n}" }
    price { 25.0 }
    association :product
  end

  factory :payment, class: 'Ddt::Payment' do
    amount { 50.0 }
    state { 'pending' }
    association :shop
    order { create(:order, shop: shop) }
  end

  factory :order, class: 'Ddt::OrderService::Order::Delivery' do
    association :shop
    association :branch
    association :user
    state { 'pending' }
    item_total { 50.0 }
    total { 50.0 }
  end

  factory :short_message_setting, class: 'Ddt::ShortMessageSetting' do
    association :shop
    use_sms { false }
    use_birthday_sms { false }
  end

  factory :role, class: 'Ddt::Role::Boss' do
    name { 'boss' }
    builtin { true }
    association :shop
  end

  factory :vip_info, class: 'Ddt::VipInfo' do
    association :shop
    association :user
    phone { user.phone }
    points { 0 }
  end

  factory :wechat_account, class: 'Ddt::WechatAccount' do
    association :shop
    gonghao_open_id { "gh_#{SecureRandom.hex(8)}" }
    app_id { SecureRandom.hex(8) }
    app_secret { SecureRandom.hex(16) }
  end
end
