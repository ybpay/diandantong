# encoding:utf-8
module Ddt
  class ChangeTableRecord < Ddt::Base
    include BelongsToBranch

    belongs_to_order
    belongs_to :from_table, class_name: 'Ddt::Table'
    belongs_to :to_table, class_name: 'Ddt::Table'
    belongs_to :operator, polymorphic: true

    set_from :order

    def notify_message
      "换台消息: 订单(#{order.try(:number)})已从(桌台:#{from_table.try(:name_with_zone)}) 换到(桌台:#{to_table.try(:name_with_zone)})"
    end

    def bill
      content = []
      content << "<CB>换台<CB>"
      content << "\n"
      content << "<CB>#{from_table.name_with_zone} --> #{to_table.name_with_zone}</CB>"
      content << "\n"
      content << "单  号: #{order.number}"
      content << "时  间: #{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
      content.join("\n")
    end

  end
end
