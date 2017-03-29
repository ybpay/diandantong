# encoding:utf-8
module Ddt
  class MergeTableRecord < Ddt::Base
    include BelongsToBranch

    belongs_to_order name: :from_order
    belongs_to_order name: :to_order
    belongs_to :from_table, class_name: 'Ddt::Table'
    belongs_to :to_table, class_name: 'Ddt::Table'
    belongs_to :operator, polymorphic: true

    set_from :from_order
    after_create :perform

    def perform
      transaction do
        self.to_table.update_columns(guest_num: self.from_table.guest_num.to_i + self.to_table.guest_num.to_i)
        self.from_table.update_columns(workflow_state: :idle, current_order_id: nil, guest_num: 0)
        self.to_table.touch
        self.from_table.touch
        self.from_order.line_items.update_all(order_id: self.to_order_id)
        self.from_order.line_item_trace_points.update_all(order_id: self.to_order_id)
        self.from_order.order_change_logs.update_all(order_id: self.to_order_id)
        self.to_order.update!
        self.from_order.update!
        self.from_order.merged
      end
      Ddt::Notification::Event::Table::Merged.create_and_send_notification(merge_table_record: self)
    end

    def notify_message
      "并台消息: 订单(#{from_order.number}), 已从(桌台: #{from_table.name_with_zone}) 并到(桌台:#{to_table.name_with_zone}), 新订单号:#{to_order.number}"
    end

    def bill
      content = []
      content << "\n"
      content << "<CB>并台<CB>"
      content << "<CB>#{from_table.name_with_zone} ==> #{to_table.name_with_zone}</CB>"
      content << "\n"
      content << "原单号: #{from_order.number}"
      content << "现单号: #{to_order.number}"
      content << "时  间: #{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
      content.join("\n")
    end

  end
end
