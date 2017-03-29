json.array! @vouchers do |voucher|
  json.partial! partial: '/ddt/weixin/user/coupon/base_index', locals: { coupon: voucher}
  json.extract! voucher, :exchange_code_state, :exchange_code_state_name, :exchange_code_id
  json.norminal_value voucher.abstract_coupon_version.norminal_value
end
