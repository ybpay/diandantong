json.cache! order.cache_key, expires_in: 2.hours do
  json.extract! order, :id, :branch_id, :number, :type, :type_str, :total, :total_in_currency, :item_count, :placed_at, :updated_at, :state, :pay_item_state, :shipment_state, :pay_item_total, :state_name, :pay_method_name, :tax_total, :pay_method, :related_order_id, :track_from, :multi_pay_item, :item_total_for_discount, :waiter_id, :waiter_name
  json.privilege_discount order.get_privilege_discount
  json.privilege_reduction order.get_privilege_reduction
  json.privilege_free order.privilege_free_adjustment.present?
  json.discount_plan order.get_discount_plan
  if order.coupon.present?
    json.coupon do
      json.id order.coupon.id
      json.extract! order.coupon.abstract_coupon_version, :name, :description
    end
  end
  if order.voucher.present?
    json.voucher do
      json.id order.voucher.id
      json.extract! order.voucher.abstract_coupon_version, :name, :description
    end
  end
  json.line_items order.line_items.active do |line_item|
    json.extract! line_item, :id, :name, :quantity, :price, :original_price, :amount, :total, :note, :gift, :itemable_type, :itemable_id, :is_change_price, :created_at, :is_append, :active_quantity, :is_moved, :is_from_move, :move_quantity, :unit_name
  end
  json.all_line_items order.line_items do |line_item|
    json.extract! line_item, :id, :name, :quantity, :price, :original_price, :amount, :total, :note, :gift, :itemable_type, :itemable_id, :is_change_price, :created_at, :is_append, :active_quantity, :is_subtract, :is_moved, :is_from_move, :move_quantity, :unit_name
  end
  json.adjustments order.adjustments.active do |adjustment|
    json.extract! adjustment, :id, :label, :amount, :amount_in_currency
  end
  json.promotion_adjustments order.adjustments.active.promotion do |adjustment|
    json.extract! adjustment, :id, :label, :amount, :amount_in_currency
    json.promotion_id adjustment.source.try(:promotion_id)
  end
  json.credits_deduction order.credits_deduction.present?
  json.card_deduction    order.card_deduction.present?
  vip_info = order.current_vip
  if vip_info.present?
    json.vip_info do
      json.extract! vip_info, :id, :vip_no, :name, :phone, :discount, :is_default
      json.credits_wallet vip_info.credits_wallet.amount
      json.card_wallet vip_info.card_wallet.amount
      if vip_info.base_user.present?
        json.user_id vip_info.base_user.id
      end
    end
  end
  json.info_items order.info_items do |item|
    json.name  item[:name]
    json.value item[:value]
  end
  json.pay_items order.pay_items do |pay_item|
    json.(pay_item, :id, :amount, :name, :name_sym, :state, :state_name, :paid_amount, :change)
    json.online pay_item.online?
    json.pay_platform pay_item.pay_platform?
  end
  json.has_moling order.moling_amount!=0
  json.has_discount_plan order.discount_plan_adjustment.present?
  json.moling_amount order.moling_amount
end
