module Ddt
  module Webpos
    module OrderBill
      extend ActiveSupport::Concern
      included do
      end

      def order_bill(order, options={})
        is_paid_bill    = options[:is_paid_bill]    rescue false
        is_product_bill = options[:is_product_bill] rescue false
        is_consume_bill = options[:is_consume_bill] rescue false
        is_reprint_bill = options[:is_reprint_bill] rescue false
        is_last_append_product_bill = options[:is_last_append_product_bill] rescue false
        case params[:bill_type].to_s
        when '58'
          order.order_detail_in_bill(
            print_spec: "58",
            is_paid_bill: is_paid_bill,
            is_product_bill: is_product_bill,
            is_consume_bill: is_consume_bill,
            is_reprint_bill: is_reprint_bill,
            is_last_append_product_bill: is_last_append_product_bill,
            bill_operator: current_account
          )
        when '80'
          order.order_detail_in_bill(
            print_spec: "80",
            is_paid_bill: is_paid_bill,
            is_product_bill: is_product_bill,
            is_consume_bill: is_consume_bill,
            is_reprint_bill: is_reprint_bill,
            is_last_append_product_bill: is_last_append_product_bill,
            bill_operator: current_account
          )
        when 'label'
          order.order_detail_in_bill(use_scene: :label, bill_operator: current_account)
        when 'html'
          order.order_detail_in_html(
            is_product_bill: is_product_bill,
            is_consume_bill: is_consume_bill,
            is_last_append_product_bill: is_last_append_product_bill,
            bill_operator: current_account
            # TODO
          )
        else
          order.order_detail_in_html
        end
      end

    end
  end
end
