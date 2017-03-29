json.coupons do
  json.array! @coupons do |coupon|
    json.extract! coupon, :id, :coupon_no
    json.name coupon.coupon_version.name
    json.coupon_min_usable_amount coupon.coupon_version.coupon_min_usable_amount
  end
end
