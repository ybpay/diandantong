json.array! @vip_levels do |vip_level|
  json.(vip_level, :id, :name, :level, :discount, :vip_infos_count, :auto_upgrade, :upgrade_total_amount, :upgrade_recharge_money, :upgrade_get_credits, :is_default)
end
