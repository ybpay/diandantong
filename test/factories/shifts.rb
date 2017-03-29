FactoryGirl.define do
  factory :shift, class: Ddt::Shift do
    shop
    branch
    created_at 1.hours.ago
  end
end
