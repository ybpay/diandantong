json.extract! @table, :id, :name, :workflow_state, :workflow_state_name, :table_zone_id, :name_with_zone, :guest_num, :guest_num_label, :updated_at, :last_opened_at, :current_order_id
if @table.current_order_id.present?
  json.order_amount @table.item_total
  json.is_from_wechat @table.is_FromWechat?
  order = @table.current_order
  if order.present?
    json.order do
      json.partial! partial: '/ddt/webpos/order/show_in_table', locals: { order: order }
    end
  end
end
