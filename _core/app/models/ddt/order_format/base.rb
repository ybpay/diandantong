#encoding: utf-8
module Ddt
  module OrderFormat
    class Base
      include Ddt::BillHelper
      attr_accessor :order
      delegate :shop, to: :order
      def initialize(order)
        @order = order
      end

      def print_setting
        @print_setting ||= order.branch.print_setting
      end
    end
  end
end
