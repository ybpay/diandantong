json.partial! partial: '/ddt/weixin/user/coupon/base_show', locals: { coupon: @groupon}
json.name_with_items @groupon.abstract_coupon_version.name_with_items
json.can_apply_refund @groupon.can_apply_refund?
json.applying_refund @groupon.applying_refund
