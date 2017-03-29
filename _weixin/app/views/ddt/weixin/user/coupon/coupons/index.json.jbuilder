json.array! @coupons do |coupon|
  json.partial! partial: '/ddt/weixin/user/coupon/base_index', locals: { coupon: coupon}
  json.(coupon, :coupon_min_usable_amount, :norminal_value, :coupon_type, :coupon_type_name, :value_desc, :product_sku)
end
