json.extract! @tuan, :id, :branch_id, :name, :groupon_price, :norminal_value, :description,
                     :support_refund, :refundable_days_after_send, :base_coupons_count,
                     :usable_starts_at, :usable_expires_at, :max_grant_limit, :branch_names
json.sellable @tuan.sellable?
json.distance_of_expires_time distance_of_time_in_words(DateTime.now, @tuan.sellable_expires_at)
json.coupon_usage_instructions @tuan.coupon_usage_instructions.map(&:content)
json.coupon_photos @tuan.coupon_photos do |photo|
  json.img photo.image_variant(:medium)
end
json.is_groupon @tuan.is_groupon?
