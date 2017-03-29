FactoryGirl.define do
  factory :table, class: Ddt::Table do
    name
    shop_id 1
    branch_id 1
    table_zone
    capacity 4
  end
end
