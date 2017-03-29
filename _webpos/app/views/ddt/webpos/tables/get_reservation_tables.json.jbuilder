json.array! @tables do |table|
  json.extract! table, :id, :name, :name_with_zone, :capacity
  json.can_reservation !@reserved_tables.include?(table)
  reservation_info = @reservation_infos.detect{|info| info.table_id == table.id}
  if reservation_info
    json.reservation_info do
      json.order_id reservation_info.reservation_order_id
      json.extract! reservation_info, :name, :phone, :gender
      json.note reservation_info.reservation_order.note
    end
  else
    json.reservation_info nil
  end
end
