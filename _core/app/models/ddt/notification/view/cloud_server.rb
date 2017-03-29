# encoding:utf-8
module Ddt
  class Notification
    module View
      class CloudServer < Ddt::Notification::View::Base

        #================================================
        # 队列
        #================================================
        [:render_queue_accepted, :render_queue_cancel, :render_queue_enqueueing, :render_queue_past, :render_queue_binded].each do |method_name|
          define_method method_name do
            msg('queue', guest_queue.id)
          end
        end

        #================================================
        # 班次
        #================================================

        def render_shift_opened
          msg('shift', event.shift_id)
        end

        def render_shift_closed
          msg('shift', event.shift_id)
        end

        #================================================
        # 桌台
        #================================================

        def render_table_opened
          msg('table', table.id)
        end

        def render_table_cleared
          msg('table', table.id)
        end

        def render_table_changed
          msg('order_change_log', order_change_log.id)
        end

        def render_table_merged
          msg('order_change_log', order_change_log.id)
        end

        def render_table_move_itemable
          msg('order_change_log', order_change_log.id)
        end

        #================================================
        # 订单
        #================================================

        [:canceled, :completed, :confirmed, :paid, :placed].each do |action|
          define_method "render_order_#{action}".to_sym do
            msg('order', order.id)
          end
        end

        [:append_itemable, :delete_itemable].each do |action|
          define_method "render_order_change_#{action}".to_sym do
            msg('order', order.id)
          end
        end

        private

        def msg(entity_type, entity_id)
          {
              shop_id: shop.id,
              branch_id: branch.id,
              entity_type: entity_type,
              entity_id: entity_id
          }
        end
      end
    end
  end
end
