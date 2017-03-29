json.partial! partial: '/ddt/weixin/user/coupon/base_show', locals: { coupon: @coupon}
json.(@coupon, :coupon_min_usable_amount, :norminal_value, :coupon_type, :coupon_type_name, :value_desc, :product_sku, :support_delivery, :support_eat_in_hall)
