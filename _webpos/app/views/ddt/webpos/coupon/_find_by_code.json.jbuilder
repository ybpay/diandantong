json.partial! partial: '/ddt/webpos/coupon/base_show', locals: { coupon: @base_coupon}
json.exchange_code @base_coupon.exchange_code.code
