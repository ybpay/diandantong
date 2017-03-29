json.array! @vip_levels do |vip_level|
  json.extract! vip_level, :id, :name, :discount, :vip_infos_count, :is_default
end
