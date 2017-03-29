module Ddt
  module Webpos
    module QueueBill
      extend ActiveSupport::Concern
      included do
      end

      def queue_bill(guest_queue)
        case params[:bill_type].to_s
        when '58'
          guest_queue.detail_in_bill('58')
        when '80'
          guest_queue.detail_in_bill('80')
        when 'html'
          guest_queue.detail_in_html
        else
          guest_queue.detail_in_html
        end
      end

    end
  end
end
