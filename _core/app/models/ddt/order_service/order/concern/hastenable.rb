module Ddt
  module OrderService
    module Order
      module Concern
        module Hastenable
          extend ActiveSupport::Concern

          def can_hasten?
            (shop_time_now - self.placed_at).to_i >= self.branch.hasten_minute_since_place.minutes.to_i
          end

          def hasten(track_from:, line_item_id:nil)
            if can_hasten?
              self.order_ext.update(:last_hasten_at => Time.now)
              Notification::Event::Order::Hasten.create_and_send_notification(order: self, line_item_id: line_item_id, track_from: track_from)
            else
              self.errors[:base] << '温馨提示：厨房收到订单时间太短，尚不需要催菜哦'
            end
          end

          def last_hasten_at
            self.order_ext.last_hasten_at
          end

          def last_hasten_at_time
            last_hasten_at.try(:to_i)
          end

          def last_hasten_at_before_now
            if last_hasten_at.present?
              seconds = (shop_time_now - last_hasten_at).to_i + 1
              seconds < 5.minutes.to_i ? seconds : nil
            end
          end

          def hasten_message(track_from:, line_item_id:nil)
            "来自#{self.class.track_from_name(track_from)} #{self.type_name} #{self.extra_info} 订单号(#{self.number}), #{self.hasten_extra_message}, 催单 #{hasten_line_item_label(line_item_id)}"
          end

          def hasten_extra_message
          end

          private
          def hasten_line_item_label(line_item_id)
            if line_item_id.blank? || line_item_id == 0
              ''
            else
              line_item = self.line_items.find(line_item_id)
              "催菜品: #{line_item.name_with_note}，"
            end
          end

        end
      end
    end
  end
end
