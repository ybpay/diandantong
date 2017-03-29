
json.partial! partial: '/ddt/webpos/coupon/base_show', locals: { coupon: @coupon}
json.exchange_code @coupon.exchange_code.code