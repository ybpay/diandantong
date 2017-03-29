FactoryGirl.define do
  factory :voucher_version, class: Ddt::VoucherVersion do
    shop_id 1
    branch_id 1
    name
    description "description"
    usable_starts_at    { 1.day.ago }
    usable_expires_at   { 1.month.since }
    sellable_starts_at  { 1.day.ago }
    sellable_expires_at { 1.month.since }
    max_grant_limit 100
    norminal_value 10
  end
end
