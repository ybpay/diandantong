json.array! @table_zones do |table_zone|
  json.extract! table_zone, :id, :name, :webpos_ban_product_ids
  json.cache! table_zone.tables.cache_key, expires_in: 1.day do
    json.tables table_zone.tables.include_current_order do |table|
      json.cache! table, expires_in: 1.day do
        json.extract! table, :id, :name, :workflow_state, :workflow_state_name, :table_zone_id, :name_with_zone, :guest_num, :guest_num_label, :last_opened_at, :updated_at
        order = table.current_order
        if order.present?
          json.current_order_id order.id
          json.order_amount order.total
          json.is_from_wechat order.is_FromWechat?
        end
      end
    end
  end
end
