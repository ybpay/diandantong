module Ddt
  module Bill
    module Order
      class Base
        attr_accessor :printer, :order, :order_change_log
        def initialize(printer, order_change_log)
          @printer = printer
          @order = order_change_log.order
          @order_change_log = order_change_log
        end
      end
    end
  end
end