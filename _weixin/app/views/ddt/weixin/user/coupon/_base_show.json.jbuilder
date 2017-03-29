json.extract! coupon, :id, :expires_at, :applied_at, :refund_at, :exchange_code_state, :exchange_code_state_name, :exchange_code_id
json.exchange_code coupon.exchange_code.code
json.expired coupon.expired?
version = coupon.abstract_coupon_version
json.extract! version, :name, :description, :branch_id
json.branch_names version.branch_names rescue nil
json.coupon_usage_instructions version.coupon_usage_instructions.map(&:content)
json.coupon_photos version.coupon_photos do |photo|
  json.img photo.image.medium.url rescue nil
end
