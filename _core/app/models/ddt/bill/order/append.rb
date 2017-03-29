# encoding: utf-8
module Ddt
  module Bill
    module Order
      class Append < Ddt::Bill::Order::Modify
        def bill_header
          header = []
          header << "<CB>加菜</CB>"
          header << "订单号:#{order.number}"
          header << "桌台信息:<B>#{order.table.try(:name_with_zone)}</B>" if order.is_eat_in_hall?
          header << "追加商品:\n"
          header.join("\n")
        end
        def bill_footer
          "\n\n追加时间:#{order_change_log.created_at}\n"
        end
      end
    end
  end
end
