json.cache! @queue_settings, expires_in: 1.day do
  json.array! @queue_settings do |queue_setting|
    json.extract! queue_setting, :id, :name, :enabled, :guest_number_interval_str, :notify_number_in_advance
  end
end