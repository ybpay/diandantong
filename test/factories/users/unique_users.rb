FactoryGirl.define do
  factory :unique_user, class: Ddt::UniqueUser do
    gonghao_open_id { Ddt::WeixinConfig.gonghao.open_id }
    user_open_id
  end
end
