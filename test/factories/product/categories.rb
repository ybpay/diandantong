FactoryGirl.define do
  factory :category, class: Ddt::Category do
    name
    branch_id 1
    shop_id 1
    factory :category_with_subs, class: Ddt::Category do
      transient do
        subs_count 1
      end
      after(:create) do |category, evaluator|
        create_list(:category, evaluator.subs_count, parent: category)
      end
    end
  end
end
