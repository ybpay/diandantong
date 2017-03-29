FactoryGirl.define do
  factory :wechat_account, class: Ddt::WechatAccount do
    shop_id 1
    gonghao_type "gonghao_service"
    gonghao_open_id { Ddt::WeixinConfig.gonghao.open_id }
    app_id          { Ddt::WeixinConfig.gonghao.app_id }
    app_secret      { Ddt::WeixinConfig.gonghao.app_secret }
    public_account_name "public_account_name"
    token "token"
    weixin_hao "weixin_hao"
    be_verified true
  end
end