json.(cart, :id, :type, :item_total, :tax_total, :adjustment_total, :total, :item_count)
json.branch_check_stock @branch.check_stock
json.line_items cart.line_items do |line_item|
  json.(line_item, :id, :itemable_type, :itemable_id, :price, :original_price, :quantity, :total,
                  :unit_name, :gift, :note, :name_with_note)
  json.name line_item.itemable_name
  itemable = line_item.itemable
  json.(itemable, :stock_quantity, :category_ids, :min_quantity_for_order)
  json.image itemable.avatar_url
end
json.adjustments cart.adjustments do |adjustment|
  json.(adjustment, :label, :amount)
end
coupon = cart.coupon
json.coupon do
  json.(coupon, :id, :coupon_no)
  json.name coupon.coupon_version.name
end if coupon.present?
json.user_id @current_user.id
unless @current_user.wifi_code
  json.user_name @current_user.nickname
  json.head_url @current_user.headimgurl
end