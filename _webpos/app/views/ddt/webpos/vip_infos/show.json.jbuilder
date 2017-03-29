json.extract! @vip_info, :id, :vip_no, :name, :phone, :email, :birthday, :vip_level_id, :vip_level_name, :vip_level_discount, :builtin, :is_default, :friendly_vip_level_discount, :total_amount, :update_times
json.user_id @vip_info.user.id rescue nil

json.card_wallet do
  json.extract! @vip_info.card_wallet, :id, :amount, :display_amount
end

json.credits_wallet do
  json.extract! @vip_info.credits_wallet, :id, :amount, :display_amount
end
