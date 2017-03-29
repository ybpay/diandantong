FactoryGirl.define do
  factory :option_type, class: Ddt::OptionType do
    shop_id 1
    branch_id 1
    name
    factory :option_type_with_option_values, class: Ddt::OptionType do
      transient do
        option_values_count 2
      end
      after(:create) do |option_type, evaluator|
        create_list(:option_value, evaluator.option_values_count, option_type: option_type)
      end
    end
  end
end
