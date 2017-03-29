if !@current_user.wifi_code
  json.headimgurl  @current_user.headimgurl
  json.sex @current_user.sex
end

json.extract! @current_user, :last_latitude, :last_longitude, :sign_records_count, :continuous_sign_count, :wifi_code
json.today_signed @current_user.today_signed?
  json.sign_history @current_user.sign_history


json.cache! [@current_user, @current_user.vip_info], expires_in: 1.day do
  json.extract! @current_user, :id, :following_branches_count, :placed_orders_count, :vip_discount, :is_blocked, :reservation_name, :reservation_phone, :reservation_gender
  json.name @current_user.nickname || @current_user.addresses.first.name rescue nil
  json.card_wallet @current_user.card_wallet.amount
  json.credits_wallet @current_user.credits_wallet.amount
  json.vip_info do
    json.extract! @current_user.vip_info, :id, :vip_no, :phone, :name, :total_amount, :is_verified, :sex, :sex_name, :address, :email, :id_number, :birthday, :total_recharge_money, :total_get_credits, :total_used_credits, :is_apply_vip, :password_not_set
    json.vip_level_name @current_user.vip_info.vip_level.name
  end
  json.is_vip @current_user.vip?
end
if @current_user.default_address.present?
  json.default_address do
    json.extract! @current_user.default_address, :id, :name, :phone, :content, :is_default, :longitude, :latitude, :city_name
  end
else
  json.default_address nil
end
