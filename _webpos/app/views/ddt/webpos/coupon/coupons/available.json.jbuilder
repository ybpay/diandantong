
json.array! @coupons do |coupon|
  json.partial! partial: '/ddt/webpos/coupon/base_show', locals: { coupon: coupon}
end