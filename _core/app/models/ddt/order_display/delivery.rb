#encoding: utf-8
module Ddt
  module OrderDisplay
    class Delivery < Ddt::OrderDisplay::Base
      def addition_info
        delivery_man = shipment.delivery_man
        data = []
        data << [:delivery_contact, '联系方式', contact_info]
        data << [:delivery_address, '配送地址', address_info]
        data << [:delivery_datetime, '配送时间', "#{order.delivery_date.strftime("%F") rescue ""} #{order.delivery_time_display}"]
        data << [:delivery_distance, '距离店铺距离(系统猜测距离，仅供参考)', "#{order.distance.try(:round, 2)}公里"] if order.is_FromWechat?
        data << [:delivery_man, '配送员', "#{delivery_man.name} #{delivery_man.phone}"] if delivery_man.present?
        make_detail_desc(data).concat(super)
      end

      def contact_info
        "#{order.delivery_name}-#{order.delivery_phone}"
      end

      def address_info
        delivery_zone_name = order.delivery_zone_name
        delivery_zone_str = delivery_zone_name.blank? ? "" : "[#{delivery_zone_name}]"
        "#{delivery_zone_str} #{order.delivery_address}"
      end

      def shipment
        @shipment ||= order.shipment
      end
    end
  end
end
