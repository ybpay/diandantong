module Ddt
  module OrderService
    module Order
      module Concern
        module SaveChangeTest
          extend ActiveSupport::Concern
          def test_save
            travel_to 1.minutes.ago do
              order
            end
            order.track_from = "FromApp"
            order.line_items.first.note = "new_note"
            assert_change %W[order.updated_at order.line_items.first.updated_at] do
              order.save
            end
          end

          def test_save_with_nested_destroy
            order.line_items.first.destroy
            assert_change "order.line_items.with_discarded.count" do
              order.save
            end
          end

          def test_save_with_nested_create
            skip # todo
          end

          def test_any_changed?
            order.track_from = "FromApp"
            assert order.any_changed?
          end

          def test_any_changed_with_nested
            order.line_items.first.note = "new_note"
            assert order.any_changed?
          end

          def test_all_changed_values
            order.track_from = "FromApp"
            assert order.all_changed_values.has_key?(:track_from)
          end

          def test_all_changed_values_with_nested
            order.line_items.first.note = "new_note"
            assert order.all_changed_values[:line_items][0].has_key?(:note)
          end

          def test_change_lock_with_pre_updated_at
            order.updated_at = 1.minute.ago
            assert_raise OrderService::Api::UpdateLockError do
              order.save
            end
          end
        end
      end
    end
  end
end