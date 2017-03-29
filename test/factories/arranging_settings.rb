FactoryGirl.define do
  factory :arranging_setting, class: Ddt::ArrangingSetting do
    shop_id 1
    branch_id 1
    mode 'free_choice'
  end
end
