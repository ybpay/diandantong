require "test_helper"
module Ddt
  module BillTemplate
    module Queue
      class EnqueueingBillTest < TestCase::Base
        let(:queue_setting) { create :queue_setting, branch: branch, shop: shop }
        let(:guest_queue) { queue_setting.new_guest_queue(base_user: nil, guest_num: 1, phone: "123123123")}
        let(:printer){ create(:normal_printer, branch: branch) }
        def test_render
          bill = BillTemplate::Queue::EnqueueingBill.new(guest_queue: guest_queue, printer: printer).render
          assert bill.include?(guest_queue.guest_no)
        end

        def test_preview
          bill = BillTemplate::Queue::EnqueueingBill.preview(branch)
          assert bill.include?("A003")
        end
      end
    end
  end
end