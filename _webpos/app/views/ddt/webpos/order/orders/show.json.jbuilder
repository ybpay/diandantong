json.cache! @order.cache_key, expires_in: 2.hours do
  json.extract! @order, :id, :number, :total, :state, :state_name, :type, :type_name, :type_str, :placed_at,
                        :pay_item_state, :pay_item_state_name, :pay_method, :pay_method_name, :place_type_name
end