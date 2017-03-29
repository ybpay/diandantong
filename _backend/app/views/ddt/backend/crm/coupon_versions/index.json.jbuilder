json.array! @coupon_versions do |coupon_version|
  json.(coupon_version,
    :id, :name, :max_grant_limit, :can_exchange, :credit_count,
    :coupon_appliable_branch_scope_policy, :coupon_appliable_branch_scope_policy_name,
    :norminal_value, :coupon_min_usable_amount,
    :usable_days_after_send, :expired_type,
    :description, :branch_ids_string, :max_count_each_user,
    :support_delivery, :support_eat_in_hall,
    :coupon_type, :product_sku, :coupon_type_name, :value_desc,
    :branch_names, :branch_ids, :branch_ids_string)
  json.usable_starts_at coupon_version.usable_starts_at.try(:strftime, "%F %H:%M")
  json.usable_expires_at coupon_version.usable_expires_at.try(:strftime, "%F %H:%M")
  json.coupon_usage_instructions coupon_version.coupon_usage_instructions do |instruction|
    json.(instruction, :id, :content)
  end
  json.coupon_photos coupon_version.coupon_photos do |photo|
    json.(photo, :id, :image)
  end
end