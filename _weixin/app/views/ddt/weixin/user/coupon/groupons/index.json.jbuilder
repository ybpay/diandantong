json.array! @groupons do |groupon|
  json.partial! partial: '/ddt/weixin/user/coupon/base_index', locals: { coupon: groupon}
  json.name_with_items groupon.abstract_coupon_version.name_with_items
  json.extract! groupon, :exchange_code_state, :exchange_code_state_name, :exchange_code_id
end
