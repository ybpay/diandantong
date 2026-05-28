json.extract! branch, :id, :name, :notice, :note_placeholder, :moling_auto, :phone, :address, :use_reservation_setting, :is_charge_by_distance, :open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday, :open_on_friday, :open_on_saturday, :open_on_sunday

  if branch.cs_branch_binding.present?
    json.http_proxy_url branch.cs_branch_binding.http_proxy_url
  end
  json.image_url branch.image_variant(:thumb)
  json.on_shift branch.current_shift.present?
  json.shift_account_id branch.current_shift.try(:account_id)
  json.shift_account_name branch.current_shift.try(:account_name)

  if branch.use_reservation_setting
    json.reservation_setting do
      json.extract! branch.reservation_setting, :max_reservation_days
    end
  end

  if branch.use_delivery_setting
    json.delivery_setting do
      json.today_can_order branch.delivery_setting.today_can_order?
      json.receive_delivery_order_within_days branch.delivery_setting.receive_delivery_order_within_days
    end
    json.delivery_times do
      json.array! branch.delivery_times, :id, :display
    end
  end

  json.pay_methods current_shop.pay_methods.enable do |pay_method|
    json.(pay_method, :id, :name, :name_sym, :name_abbr, :builtin, :code)
  end
  json.is_support_alipay    current_shop.current_alipay_method.present?
  json.is_support_wechatpay current_shop.current_wechatpay_method.present?
  #json.is_support_baidupay @current_shop.current_baidupay_method.present?
  json.order_cancel_reasons do
    json.array! Ddt::Order::CANCEL_REASONS
  end

  json.arranging_setting_mode branch.arranging_setting.mode
  json.enable_tts_local       branch.enable_tts_local
  json.accessable_ssid_for_app branch.eat_in_hall_setting.accessable_ssid_for_app.presence
