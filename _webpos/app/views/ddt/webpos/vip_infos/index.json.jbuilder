json.array! @vip_infos do |vip_info|
  json.extract! vip_info, :id, :vip_no, :name, :phone, :email, :vip_level_name, :vip_level_discount, :friendly_vip_level_discount, :builtin, :is_default, :is_apply_vip, :total_amount, :update_times
  json.vip_level_id vip_info.vip_level.id
  json.user_id vip_info.user.try(:id)

  json.card_wallet do
    json.extract! vip_info.card_wallet, :id, :amount, :display_amount
  end

  json.credits_wallet do
    json.extract! vip_info.credits_wallet, :id, :amount, :display_amount
  end
end
