# encoding: utf-8
module Ddt
  module Bill
    module Order
      class Reprint < Ddt::Bill::Order::Base
        attr_accessor :reprint_event
        def initialize(printer, reprint_event)
          @printer = printer
          @reprint_event = reprint_event
          @order = reprint_event.order
        end

        def header
          "<CB>补打</CB>"
        end

        def content
          detail = order.order_detail_in_bill(printer: printer)
          if detail.class == Array
            detail.map {|bill| bill = [header, bill, footer].join("\n")}
          else
            detail = [header, detail, footer].join("\n")
          end
        end

        private
        def footer
          text = []
          text << "补打时间: #{reprint_event.created_at_str}"
          text << "备注: #{reprint_event.note}" if reprint_event.note.present?
          text.join("\n")
        end

      end
    end
  end
end
