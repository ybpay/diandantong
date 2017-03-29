json.data do
  Ddt::NotificationReceiveSetting.all_settings.each do |s|
    json.extract! @notification_receive_setting, s
  end
end

json.label do
  Ddt::NotificationReceiveSetting.all_settings.each do |s|
    json.set!(s, Ddt::NotificationReceiveSetting.setting_name(s))
  end
end