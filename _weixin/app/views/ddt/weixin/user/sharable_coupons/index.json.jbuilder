json.array! @sharable_coupons do |sharable_coupon|
  json.extract! sharable_coupon, :id, :coupon_version_name, :count, :receive_count
end