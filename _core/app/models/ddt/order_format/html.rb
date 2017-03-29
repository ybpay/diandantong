module Ddt
  module OrderFormat
    class Html < Ddt::OrderFormat::Base

      attr_accessor :order, :is_product_bill, :bill_operator

      def initialize(order, options={})
        @order = order
        @is_product_bill = options[:is_product_bill]
        @bill_operator = options[:bill_operator]
      end

      def content
        printer = Printer::Normal.new(print_spec: "58")
        if is_product_bill
          bill = BillTemplate::Order::ProductBill.new(order: order, printer: printer, bill_operator: bill_operator).render
          bill = BillTemplateSetting.transform_bill_to_html(bill).gsub("&nbsp;", " ")
        else
          bill = BillTemplate::Order::Bill.new(order: order, printer: printer, bill_operator: bill_operator).render
          bill = BillTemplateSetting.transform_bill_to_html(bill).gsub("&nbsp;", " ")
        end
      end
    end
  end
end
