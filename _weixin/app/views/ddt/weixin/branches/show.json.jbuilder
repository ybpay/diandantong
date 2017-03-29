json.is_followed @branch.is_followed_by(@current_user)
json.delivery_today_can_order @branch.delivery_setting.today_can_order?
json.extract! @branch, :is_in_service
json.delivery_dates @branch.delivery_dates
json.cache! [@branch], expires_in: 1.day do


  json.extract! @branch, :id, :name, :address, :latitude, :longitude, :average_consumption, :use_delivery_setting, :use_reservation_setting, :use_eat_in_hall_setting, :use_fastfood_setting, :use_queue_setting, :use_pay_online_setting, :phone, :notice, :note_placeholder, :rating, :wechat_no, :qq_no, :branch_type_id, :check_stock, :support_wifi, :support_parking, :parking_space_count, :support_invoice, :introduction, :show_stock_quantity, :show_sale_quantity, :enable_user_location_limitation

  json.eat_in_hall_mode @branch.eat_in_hall_setting.mode
  json.can_place_when_zero @branch.eat_in_hall_setting.can_place_when_zero
  json.disable_service @branch.disable_service
  json.comments_count @branch.branch_comments.of_published.count
  json.image @branch.image.medium.url
  json.rect_image @branch.rect_image.medium.url
  json.has_combo @branch.combos.of_wechat.available.on_shelf.sale_on_now.by_support_type(params[:order_type]).count > 0

  json.has_essential_product @branch.essential_products.count > 0

  json.partial! partial: '/ddt/weixin/branches/delivery_setting', locals: {branch: @branch}

  unless @branch.is_abstract?
    json.arranging_setting do
      json.extract! @branch.arranging_setting, :mode
    end
  end

  json.tags @branch.all_tags do |tag|
      json.extract! tag, :id, :name, :color
  end

  json.service_periods @branch.service_periods.each do |service_period|
    json.start_at service_period.fstart_at
    json.end_at service_period.fend_at
  end

  json.waiter_service_items do
    json.array! @branch.waiter_service_items do |waiter_service_item|
      json.extract! waiter_service_item, :name
    end
  end
  if @current_shop.has_feature?(:base_groupon)
    json.tuans @branch.tuans.tuans_on_sale.each do |tuan|
     json.extract! tuan, :id, :name, :type, :base_coupons_count, :description, :groupon_price
     json.image tuan.coupon_photos.first.image.thumb.url if tuan.coupon_photos.any?
    end
  else
    json.tuans []
  end
  if @branch.use_fixed_delivery_time
    json.delivery_times @branch.delivery_times.each do |delivery_time|
      json.extract! delivery_time, :id, :start_time, :end_time
    end
  end

  if @branch.use_reservation_setting
    json.reservation_setting do
      json.extract! @branch.reservation_setting, :average_consumption, :prepayment_type, :max_reservation_days
    end
  end


  json.comments do
    json.partial! partial: '/ddt/weixin/comments/comments', locals: { comments: @branch.branch_comments.of_published.limit(5) }
  end

  json.form_elements @form_elements.each do |form_element|
    json.id form_element.id
    json.label form_element.statement
    json.type form_element.type
    json.placeholder form_element.placeholder if form_element.placeholder.present?
    #json.need form_element.need if form_element.need && form_element.need.present?
    json.support_order_types form_element.support_order_types
    if form_element.options.present?
      json.options form_element.options do |option|
        json.option_id option.id
        json.html option.statement
      end
      json.options_hash Hash[form_element.options.map { |o| [o.id, o.statement] } ]
    end
    json.need form_element.need

    if form_element.is_a? Ddt::FormElementText
      json.record do
        json.type form_element.type
        json.form_element_id form_element.id
        json.content ""
      end
    end
    if form_element.is_a? Ddt::FormElementSelect
      json.record do
        json.type form_element.type
        json.form_element_id form_element.id
      end
    end
  end

  json.delivery_zones do
    json.array! @branch.delivery_zones, :id, :zone_name, :cost
  end

  json.pay_method_setting @branch.all_pay_methods
end
