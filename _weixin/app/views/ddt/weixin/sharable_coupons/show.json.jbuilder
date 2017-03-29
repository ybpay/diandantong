json.extract! @sharable_coupon, :id, :coupon_version_name, :count, :receive_count, :created_at
json.received_users @sharable_coupon.received_users do |user|
  json.extract! user, :id, :nickname, :headimgurl
end