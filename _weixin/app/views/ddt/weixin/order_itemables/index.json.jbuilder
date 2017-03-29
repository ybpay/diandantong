json.array! @merge_order_itemables_groups.map do |base_user_id, itemables|
  if base_user_id.present?
    if cookies[:wifi_code].present?
      user = Ddt::WifiUser.find(base_user_id)
      json.user_id base_user_id
    else
      user = Ddt::User.find(base_user_id)
      json.user_id base_user_id
      json.user_name user.nickname
      json.head_url user.headimgurl
    end
  else
    json.user_id -1
    json.user_name '必选品'
    json.head_url nil
  end

  json.itemables itemables.each do |itemable|
    json.(itemable, :id, :itemable_type, :itemable_id, :quantity, :note, :name, :name_with_note, :price)
  end
  json.count itemables.map(&:quantity).sum
end
