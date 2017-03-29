json.array! @table_zones do |table_zone|
  json.extract! table_zone, :id, :name, :tables_count
  json.cache! table_zone.tables.cache_key, expires_in: 1.day do
    json.tables table_zone.tables.include_current_order do |table|
      json.cache! table, expires_in: 1.day do
        json.extract! table, :id, :name, :workflow_state, :workflow_state_name, :name_with_zone, :guest_num, :guest_num_label, :capacity, :updated_at
        order = table.current_order
        if order.present?
          json.order_amount order.item_total_in_currency
          json.is_from_wechat order.is_FromWechat?
        end
      end
    end
  end
end
