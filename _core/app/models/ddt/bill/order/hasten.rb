# encoding: utf-8
module Ddt
  module Bill
    module Order
      class Hasten < Ddt::Bill::Order::Base
        attr_accessor :hasten_event, :line_item, :can_print

        def initialize(printer, hasten_event)
          @can_print = true
          @printer = printer
          @hasten_event = hasten_event
          @order = hasten_event.order
          if !@printer.concern_table(order)
            @can_print = false
            return
          end
          line_item_id = hasten_event.line_item_id
          if line_item_id.present? && line_item_id != 0
            @line_item = @order.line_items.find(line_item_id)
            @can_print = false if !@printer.concern_line_item([@line_item])
          end
        end

        def header
          "<CB>催菜</CB>"
        end

        def content
          return if !can_print
          detail = []
          detail << "<M>桌台: </M><B>#{order.table.try(:name_with_zone)}</B>" if order.is_eat_in_hall?
          detail << "<M>牌号: </M><B>#{order.food_number}</B>" if order.is_fastfood?
          if order.is_delivery?
            displayer = order.displayer
            detail << "<M>联系人: </M><B>#{displayer.contact_info}</B>"
            detail << "<M>地址: </M><B>#{displayer.address_info}</B>"
          end
          if line_item.present?
            detail << "<M>催菜品: </M><B>#{line_item.name_with_note}</B>"
          else
            detail << "<CB>催整单</CB>"
          end
          detail = [header, detail.join("\n"), footer].join("\n")
        end

        private
        def footer
          text = []
          text << (Ddt::TrackFrom::WEBPOS == hasten_event.track_from ? '来源: 收银端' : '来源: 微信')
          text << "订单编号: #{order.number}"
          if line_item.present?
            time_passed = hasten_event.created_at_time - line_item.created_at
            text << "催菜时间: #{hasten_event.created_at_str}"
          else
            time_passed = hasten_event.created_at_time - order.placed_at
            text << "催单时间: #{hasten_event.created_at_str}"
          end
          text << "下单时间: #{order.placed_at}"
          text << "已过时间: #{Ddt::TimeUtil.label_of_second(time_passed)}"
          text.join("\n")
        end

      end
    end
  end
end
