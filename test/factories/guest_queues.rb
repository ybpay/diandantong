FactoryGirl.define do
  factory :guest_queue, class: Ddt::GuestQueue do
    shop_id 1
    branch_id 1
    queue_setting_id 1
    phone
    guest_num 2
    workflow_state 'queueing'
  end
end
