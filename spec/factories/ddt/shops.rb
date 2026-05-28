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

  factory :category, class: 'Ddt::Category' do
    sequence(:name) { |n| "测试分类#{n}" }
    association :shop
    association :branch
    position { 1 }
    support_delivery { true }
    support_reservation { true }
    support_eat_in_hall { true }
    show_on_wechat { true }
    enable_discount { true }
  end

  factory :vip_level, class: 'Ddt::VipLevel' do
    association :shop
    sequence(:name) { |n| "VIP等级#{n}" }
    level { 1 }
    discount { 0.95 }
    is_default { false }
    auto_upgrade { false }
    upgrade_total_amount { 0 }
    upgrade_recharge_money { 0 }
    upgrade_get_credits { 0 }

    trait :default do
      is_default { true }
      level { 1 }
      discount { 1.0 }
    end
  end

  factory :table_zone, class: 'Ddt::TableZone' do
    sequence(:name) { |n| "区域#{n}" }
    association :shop
    association :branch
    tables_count { 0 }
    tables_count_for_reservation { 0 }
    min_reservation_price { 0.0 }
    reservation_price { 0.0 }
    reservation_price_percent { 100 }
  end

  factory :table, class: 'Ddt::Table' do
    sequence(:name) { |n| "桌台#{n}" }
    association :table_zone
    association :shop
    association :branch
    capacity { 4 }
    workflow_state { 'idle' }
  end

  factory :queue_setting, class: 'Ddt::QueueSetting' do
    sequence(:name) { |n| "排队设置#{n}" }
    association :shop
    association :branch
    guest_num_le { 4 }
    start_at { '09:00' }
    end_at { '22:00' }
    enabled { true }
    notify_number_in_advance { 3 }
  end

  factory :guest_queue, class: 'Ddt::GuestQueue' do
    association :shop
    association :branch
    association :queue_setting
    guest_num { 2 }
    guest_no { "A001" }
    workflow_state { 'queueing' }
  end

  factory :shift, class: 'Ddt::Shift' do
    association :shop
    association :branch
    association :account
    state { 'opening' }
    total_amount { 0 }
  end

  factory :payment_method, class: 'Ddt::PaymentMethod' do
    sequence(:name) { |n| "支付方式#{n}" }
    association :shop
    active { true }
  end

  factory :coupon_version, class: 'Ddt::CouponVersion' do
    sequence(:name) { |n| "优惠券活动#{n}" }
    association :shop
    norminal_value { 10.0 }
    coupon_min_usable_amount { 50.0 }
    usable_starts_at { 1.day.ago }
    usable_expires_at { 1.year.from_now }
    max_grant_limit { 1000 }
  end

  factory :voucher_version, class: 'Ddt::VoucherVersion' do
    sequence(:name) { |n| "代金券活动#{n}" }
    association :shop
    norminal_value { 20.0 }
    coupon_min_usable_amount { 50.0 }
    usable_starts_at { 1.day.ago }
    usable_expires_at { 1.year.from_now }
    max_grant_limit { 500 }
  end

  factory :groupon_version, class: 'Ddt::GrouponVersion' do
    sequence(:name) { |n| "团购活动#{n}" }
    association :shop
    norminal_value { 50.0 }
    groupon_price { 39.9 }
    usable_starts_at { 1.day.ago }
    usable_expires_at { 1.year.from_now }
    max_grant_limit { 200 }
  end

  factory :coupon, class: 'Ddt::Coupon' do
    association :shop
    association :base_user, factory: :user
    association :coupon_version
    expires_at { 1.year.from_now }
    coupon_no { "CP#{SecureRandom.hex(4).upcase}" }
  end

  factory :voucher, class: 'Ddt::Voucher' do
    association :shop
    association :base_user, factory: :user
    association :voucher_version
    expires_at { 1.year.from_now }
    coupon_no { "VC#{SecureRandom.hex(4).upcase}" }
  end

  factory :groupon, class: 'Ddt::Groupon' do
    association :shop
    association :base_user, factory: :user
    association :groupon_version
    expires_at { 1.year.from_now }
    coupon_no { "GP#{SecureRandom.hex(4).upcase}" }
  end

  factory :order_itemable, class: 'Ddt::OrderItemable' do
    association :shop
    association :branch
    association :user
    quantity { 1 }
  end
end
