json.cache! [@current_shop, @branch], expires_in: 1.day do
  json.extract! @branch, :id, :name, :use_reservation_setting, :is_charge_by_distance, :moling_auto, :is_abstract, :latitude, :longitude
  json.on_shift @branch.current_shift.present?
  json.shift_account_id @branch.current_shift.try(:account_id)
  json.shift_account_name @branch.current_shift.try(:account_name)

  if @branch.use_reservation_setting
    json.reservation_setting do
      json.extract! @branch.reservation_setting, :max_reservation_days
    end
  end

  if @branch.use_delivery_setting
    json.delivery_setting do
      json.today_can_order @branch.delivery_setting.today_can_order?
      json.receive_delivery_order_within_days @branch.delivery_setting.receive_delivery_order_within_days
    end
    json.delivery_times do
      json.array! @branch.delivery_times, :id, :display
    end
  end
  json.pay_methods @current_shop.pay_methods.enable do |pay_method|
    json.(pay_method, :id, :name, :name_sym, :name_abbr, :builtin, :code, :enable_negative, :support_delivery, :support_eat_in_hall, :support_fastfood, :support_reservation, :support_groupon, :support_recharge, :support_payment)
  end
  json.is_support_alipay    @current_shop.current_alipay_method.present?
  json.is_support_wechatpay @current_shop.current_wechatpay_method.present?
  #json.is_support_baidupay @current_shop.current_baidupay_method.present?
  json.order_cancel_reasons do
    json.array! Ddt::Order::CANCEL_REASONS
  end

  json.arranging_setting_mode @branch.arranging_setting.mode
  json.enable_tts_local       @branch.enable_tts_local
  json.litp_warning_wait_minitue @branch.kitchen_setting.warning_wait_minitue
end
json.open_shift_num @branch.shifts.where(closed_at: Time.now.midnight..Time.now, account_id: current_account.id).count
json.is_current_print_when_place @branch.print_setting.is_current_print_when_place
json.webpos_autoprinter_configed @branch.webpos_printer_configed?
json.credits_exchange_radio @current_shop.credits_setting.exchange_radio
json.enable_sdu @branch.sale_data_uploader_setting.enable?
json.auto_upload_after_shift @branch.sale_data_uploader_setting.auto_upload_after_shift?
json.vip_enable_blur_search current_shop.vip_info_setting.enable_blur_search

json.vip_recharge_type current_shop.vip_info_setting.recharge_type
json.can_change_vip_level_in_webpos current_shop.vip_info_setting.can_change_vip_level_in_webpos
json.disable_recharge_when_query current_shop.vip_info_setting.disable_recharge_when_query
json.allow_credits_exchange_and_get current_shop.vip_info_setting.allow_credits_exchange_and_get
json.enable_query_for_settle current_shop.vip_info_setting.enable_query_for_settle
