json.(@coupon,
  :coupon_min_usable_amount, :norminal_value, :coupon_type, :coupon_type_name,
  :value_desc, :product_sku, :support_delivery, :support_eat_in_hall,
  :id, :expires_at, :applied_at, :refund_at, :exchange_code_state, :exchange_code_state_name, :exchange_code_id)
json.exchange_code @coupon.exchange_code.code
json.expired @coupon.expired?
version = @coupon.abstract_coupon_version
json.extract! version, :name, :description, :branch_id
json.branch_name version.branch.name rescue nil
json.coupon_usage_instructions version.coupon_usage_instructions.map(&:content)
json.coupon_photos version.coupon_photos do |photo|
  json.img photo.image.medium.url rescue nil
end
