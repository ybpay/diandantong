
json.array! @vouchers do |voucher|
  json.partial! partial: '/ddt/webpos/coupon/base_show', locals: { coupon: voucher}
  json.exchange_code voucher.exchange_code.code
end