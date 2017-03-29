json.array! @tables do |table|
  json.extract! table, :id, :name, :workflow_state, :workflow_state_name, :name_with_zone, :guest_num, :guest_num_label, :capacity, :current_order_id, :table_zone_id, :updated_at, :last_opened_at
  json.table_zone_name table.table_zone.name
  # 暂无使用到该数据, 为了速度，注释之
  #order = table.current_order
  #if order.present?
  #  json.order_amount order.item_total_in_currency
  #  json.is_from_wechat order.is_FromWechat?
  #end
end
