
json.extract! @table,
  :id,
  :name,
  :workflow_state,
  :workflow_state_name,
  :name_with_zone,
  :guest_num,
  :guest_num_label,
  :capacity,
  :updated_at,
  :current_order_id,
  :qr_code_image,
  :table_zone_id,
  :last_opened_at
json.table_zone_name @table.table_zone.name
