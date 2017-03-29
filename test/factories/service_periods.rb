FactoryGirl.define do
  factory :service_period, class: Ddt::ServicePeriod do
    start_at "00:00"
    end_at   "23:59"
    branch_id 1
    shop_id 1
  end
end
