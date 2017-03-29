json.array! @tuans do |tuan|
  json.extract! tuan, :id, :branch_id, :name, :groupon_price, :norminal_value, :base_coupons_count, :branch_names
  json.photo tuan.coupon_photos.first.try(:image).try(:thumb_square).try(:url)
end