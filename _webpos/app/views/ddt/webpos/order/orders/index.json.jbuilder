json.array! @orders do |order|
  json.cache! order.cache_key, expires_in: 2.hours do
    json.extract! order,  :id, :number, :total, :amount_for_pay, :pay_item_total, :state, :state_name, :type, :type_name, :placed_at, :type_str, :pay_item_state, :pay_item_state_name, :pay_method, :pay_method_name, :place_type_name, :food_number

    if order.is_delivery?
      json.delivery_man_name order.delivery_man_name
      json.contact_info "#{order.delivery_name}-#{order.delivery_phone}"
      json.address order.delivery_address
    end
    if order.is_eat_in_hall? && order.table.present?
      json.table_name order.table.name_with_zone
    end
    if order.is_reservation?
      json.extract! order, :reservation_time_info, :reservation_customer_info
    end
  end
end
