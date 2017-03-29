#encoding: utf-8
module Ddt
  module OrderDisplay
    class EatInHall < Ddt::OrderDisplay::Base

      def addition_info
        data = []
        data << [:eat_in_hall_table_name, '桌台信息', order.table_name_with_zone] if order.table_id.present?
        data << [:eat_in_hall_guest_num, '用餐人数', order.guest_num] if order.guest_num.present?
        data << [:eat_in_hall_waiter, '点菜员', order.waiter_name] if order.waiter_name.present?
        data << [:eat_in_hall_note, '堂点备注', "由预订订单生成 #{order.related_order.number}"] if order.related_order.present?
        make_detail_desc(data).concat(super)
      end

      def short_addition_info
        data = []
        data << [:eat_in_hall_table_name, '桌台信息', order.table_name_with_zone]
        make_detail_desc(data).concat(super)
      end
    end
  end
end
