module Ddt
  class Notification
    module View
      class Printer < Ddt::Notification::View::Base
        alias_method :printer, :target

        def render_order_placed
          order.order_detail_in_bill(printer: printer, order_change_log: order.order_change_logs.place_log, bill_operator: event.operator)
        end

        def render_order_paid
          order.order_detail_in_bill(printer: printer, is_paid_bill: true, bill_operator: event.operator)
        end

        def render_order_confirmed
          bills = []
          bills << order.order_detail_in_bill(printer: printer, order_change_log: order.order_change_logs.place_log, bill_operator: event.operator)
          append_logs_before_confirm = order.order_change_logs.append_itemable.select{|l| l.created_at < event.created_at_time }
          if append_logs_before_confirm.present?
            append_logs_before_confirm.each do |log|
              bills << order_append_bill_of_log(log)
            end
          end
          bills.flatten.compact
        end

        def render_order_request_pay
           order.request_pay_message + "(支付方式: #{event.pay_method_name})"
        end

        def render_table_changed
          order_change_log.change_table_bill
        end

        def render_table_merged
          order_change_log.merge_table_bill
        end

        def render_table_move_itemable
          order_change_log.move_itemable_bill
        end

        def render_table_check_out
          event.order.order_detail_in_bill(printer: printer, is_consume_bill: true, bill_operator: event.operator)
        end

        def render_order_reprint
          BillTemplate::Order::ReprintBill.new(order: event.order, printer: printer, event: event).render
        end

        def render_order_change_append_itemable
          order_append_bill_of_log(order_change_log)
        end

        def render_order_change_delete_itemable
          return if !printer.concern_table(order)
          return if !printer.concern_line_item(order.line_items.by_log(order_change_log))
          if printer.print_per_product?
            BillTemplate::Order::SubtractPerProductBill.new(order: order, printer: printer, order_change_log: order_change_log).render
          elsif printer.print_one_by_one?
            BillTemplate::Order::SubtractOneByOneBill.new(order: order, printer: printer, order_change_log: order_change_log).render
          else
            BillTemplate::Order::SubtractBill.new(order: order, printer: printer, order_change_log: order_change_log).render
          end
        end

        def render_order_hasten
          return if !printer.concern_table(order)
          if event.line_item_id.present? && event.line_item_id > 0
            return if !printer.concern_line_item(order.line_items.select{|line_item| line_item.id == event.line_item_id})
            BillTemplate::Order::HastenItemBill.new(order: order, printer: printer, event: event).render
          else
            return if !printer.concern_line_item(order.line_items.active)
            BillTemplate::Order::HastenBill.new(order: order, printer: printer, event: event).render
          end
        end

        def render_queue_enqueueing
          BillTemplate::Queue::EnqueueingBill.new(guest_queue:guest_queue, printer:printer).render
        end

        def render_queue_reprint
          BillTemplate::Queue::EnqueueingBill.new(guest_queue:guest_queue, printer:printer).render
        end

        def render_queue_print_pre_order
          BillTemplate::Queue::PreOrderBill.new(guest_queue:guest_queue, printer:printer).render
        end

        def render_product_stock_empty
          "产品估清消息: 产品#{event.variant.name_with_options_text}已估清"
        end

        private
        def order_append_bill_of_log(log)
          return if !printer.concern_table(order)
          return if !printer.concern_line_item(order.line_items.by_log(log))
          if printer.is_guest?
            BillTemplate::Order::AppendProductBill.new(order: order, printer: printer, order_change_log: log).render
          elsif printer.is_label?
            BillTemplate::Order::LabelBill.new(order: order, printer: printer, order_change_log: log).render
          else
            if printer.print_per_product?
              BillTemplate::Order::AppendPerProductBill.new(order: order, printer: printer, order_change_log: log).render
            elsif printer.print_one_by_one?
              BillTemplate::Order::AppendOneByOneBill.new(order: order, printer: printer, order_change_log: log).render
            else
              BillTemplate::Order::AppendBill.new(order: order, printer: printer, order_change_log: log).render
            end
          end
        end
      end
    end
  end
end
