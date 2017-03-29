
json.array! @coupon_versions do |coupon_version|
  json.extract! coupon_version, :id, :name, :description, :usable_starts_at, :usable_expires_at, :can_exchange, :credit_count, :branch_id, :coupon_min_usable_amount, :norminal_value
  json.max_count_each_user (coupon_version.max_count_each_user || 1000)
  json.branch_name coupon_version.brannch.name rescue nil
end
