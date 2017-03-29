json.partial! partial: '/ddt/weixin/user/coupon/base_show', locals: { coupon: @voucher}
json.can_apply_refund @voucher.can_apply_refund?
json.applying_refund @voucher.applying_refund
