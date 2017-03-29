FactoryGirl.define do
  factory :wechat_user, class: Ddt::WechatUser do
    shop_id 1
    gonghao_open_id { Ddt::WeixinConfig.gonghao.open_id }
    user_open_id
  end
end
