module Ddt
  module Bill
    module Queue
      class Base
        include BillHelper
        attr_accessor :guest_queue, :printer
        delegate :queue_setting, :branch, :shop, to: :guest_queue
        def initialize(guest_queue, printer)
          @guest_queue = guest_queue
          @printer = printer
        end
      end
    end
  end
end
