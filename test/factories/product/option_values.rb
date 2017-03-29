FactoryGirl.define do
  factory :option_value, class: Ddt::OptionValue do
    shop_id 1
    branch_id 1
    option_type
    name
  end
end
