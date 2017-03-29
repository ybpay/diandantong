json.array! branches do |branch|
  json.distance branch.distance_to(@current_user, units: :kms) * 1000
  json.delivery_today_can_order branch.delivery_setting.today_can_order?
  json.extract! branch, :is_in_service
  json.cache! [branch], expires_in: 1.day do
    json.extract! branch,
                  :id,
                  :name,
                  :latitude,
                  :longitude,
                  :address,
                  :use_reservation_setting,
                  :use_delivery_setting,
                  :use_eat_in_hall_setting,
                  :placed_orders_count,
                  :rating,
                  :position,
                  :support_wifi,
                  :support_parking
    json.partial! partial: '/ddt/weixin/branches/delivery_setting', locals: {branch: branch}

    json.delivery_times branch.delivery_times do |delivery_time|
      json.extract! delivery_time, :fstart_time, :fend_time
    end
    json.top_sales branch.top_sales.map(&:name)
    json.image branch.image.thumb.url
    if has_feature?(:base_groupon)
      json.tuans branch.tuans.tuans_on_sale.limit(2).each do |tuan|
        json.extract! tuan, :id, :name, :type
      end
    else
      json.tuans []
    end

    if has_feature?(:base_event_promotion)
      promotions = (branch.promotions.active + branch.shop.promotions.active.active_in_branch(branch)).uniq
      json.promotions promotions.each do |promotion|
        json.extract! promotion, :id, :type, :name, :description
      end
    else
      json.promotions []
    end
  end
end
