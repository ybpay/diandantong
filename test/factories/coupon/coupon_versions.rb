FactoryGirl.define do
  factory :coupon_version, class: Ddt::CouponVersion do
    shop_id 1
    name
    description "description"
    coupon_appliable_branch_scope_policy :appliable_to_any_branch
    usable_starts_at    { 1.day.ago }
    usable_expires_at   { 1.month.since }
    max_grant_limit 100
    norminal_value 1
    coupon_min_usable_amount 10
  end
end
