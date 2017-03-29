FactoryGirl.define do
  factory :queue_setting, class: Ddt::QueueSetting do
    shop_id 1
    branch_id 1
    name
    guest_num_le 1
    notify_number_in_advance 1
    start_at "00:01"
    end_at   "23:59"
  end
end
