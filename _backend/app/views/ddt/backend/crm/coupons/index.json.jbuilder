json.array! @coupons do |coupon|
  version = coupon.abstract_coupon_version
  user = coupon.base_user
  json.(coupon, :id, :coupon_no, :norminal_value, :coupon_min_usable_amount, :support_delivery, :support_eat_in_hall, :expires_at, :applied_at, :coupon_type, :coupon_type_name,
    :value_desc, :product_sku,
    :refund_at, :exchange_code_state, :exchange_code_state_name, :exchange_code_id)
  json.exchange_code coupon.exchange_code.code
  json.extract! version, :name, :description, :branch_id, :value_desc
  json.branch_name version.branch.name rescue nil
  json.coupon_usage_instructions version.coupon_usage_instructions.map(&:content)
  json.expired coupon.expired?

  json.user_msg user.to_label rescue coupon.base_user_id
end
