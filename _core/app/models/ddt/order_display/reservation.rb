#encoding: utf-8
module Ddt
  module OrderDisplay
    class Reservation < Ddt::OrderDisplay::Base
      def addition_info
        data = []
        data << [:reservation_customer_info, '预订人信息', order.reservation_customer_info] if order.reservation_info.present?
        data << [:reservation_time_info, '预定时间', order.reservation_time_info] if order.reservation_info.present?
        data << [:reservation_note, '预订备注', @order.reservation_note] if order.related_order.present?
        make_detail_desc(data).concat(super)
      end
    end
  end
end