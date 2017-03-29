
json.extract! @coupon_version, :id, :name, :description, :usable_starts_at, :usable_expires_at, :can_exchange, :credit_count, :branch_id, :coupon_min_usable_amount, :norminal_value, :coupon_type_name, :support_delivery, :support_eat_in_hall
json.max_count_each_user (@coupon_version.max_count_each_user || 1000)
json.branch_name @coupon_version.brannch.name rescue nil
json.coupon_usage_instructions @coupon_version.coupon_usage_instructions.map(&:content)
json.coupon_photos @coupon_version.coupon_photos do |photo|
  json.img photo.image.medium.url rescue nil
end
