FactoryGirl.define do
  factory :account, class: Ddt::Account do
    login_id
    name
    email
    phone
    password "12345678"
    password_confirmation "12345678"
    captcha_valid true
    built_in false
    shop_id 1
    [:boss,:worker,:deliveryman,:cook,:chef,:waiter,:cashier,:vip_info_manager,:queue_waiter].each do |role_name|
      factory role_name, class: Ddt::Account do
        after(:create) do |account|
          account.roles = account.shop.roles.send("#{role_name}_role") if account.shop.present?
        end
      end
    end
  end
end
