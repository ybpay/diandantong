json.queue_settings @queue_settings.each do |queue_setting|
  json.extract! queue_setting, :id, :name, :last_push_queue_item_no, :guest_num_le
  json.guest_num_ge @last_guest_num_le + 1
  @last_guest_num_le = queue_setting.guest_num_le
  json.current_queue_head queue_setting.current_queue_head.guest_no rescue nil
  json.queueing_guests_num queue_setting.queueing_guests.count
end
if @my_queue.present?
  json.my_queue do
    json.extract! @my_queue, :id, :guest_no
    json.current_queue_head @my_queue.queue_setting.current_queue_head.guest_no rescue nil
    json.queue_setting_name @my_queue.queue_setting.name
    json.guest_num_at_front @my_queue.guest_num_at_front
  end
end
