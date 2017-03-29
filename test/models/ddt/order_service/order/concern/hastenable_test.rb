module Ddt
  module OrderService
    module Order
      module Concern
        module HastenableTest
          extend ActiveSupport::Concern

          def test_hasten
            travel_to 1.minute.ago do
              order
            end
            assert_change "order.last_hasten_at" do
              order.hasten(track_from: :FromWebpos)
            end
          end

          def test_hasten_message
            travel_to 1.minute.ago do
              order
            end
            order.hasten(track_from: :FromWebpos)
            assert order.hasten_extra_message.present?
            assert order.hasten_message(track_from: :FromWebpos).present?
          end

        end
      end
    end
  end
end
