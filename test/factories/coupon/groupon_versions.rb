FactoryGirl.define do
  factory :groupon_version, class: Ddt::GrouponVersion do
    shop_id 1
    branch_id 1
    name
    description "description"
    usable_starts_at    { 1.day.ago }
    usable_expires_at   { 1.month.since }
    sellable_starts_at  { 1.day.ago }
    sellable_expires_at { 1.month.since }
    groupon_price 100
    max_grant_limit 100
    # groupon_line_items { [create(:groupon_line_item)] }
  end
end
