module Ddt
  module OrderService
    class OrderChangeLog
      include OrderService::Concern::Base
      include OrderService::Concern::BelongsToOrder
      belongs_to :operator, polymorphic: true
      belongs_to :from_table, ->{with_discarded}, class_name: "Ddt::Table"
      belongs_to :to_table, ->{with_discarded}, class_name: "Ddt::Table"
      belongs_to_order name: :from_order
      belongs_to_order name: :to_order
      attr_accessor_with_dirty :id, :type, :description, :created_at, :updated_at, :from_order_id, :to_order_id, :operator_name, :deleted_at, :delete_by_admin, :sync_at
      attr_accessor :change_table_record_id, :merge_table_record_id # 数据迁移暂存字段
      def initialize(params={})
        super
        set_operator_name
        set_timestamps if new?
        changes_applied if exists?
      end

      acts_as_type :type, [
          "Ddt::OrderChangeLog::AppendItemable",
          "Ddt::OrderChangeLog::DeleteItemable",
          "Ddt::OrderChangeLog::MoveItemable",
          "Ddt::OrderChangeLog::OrderCancel",
          "Ddt::OrderChangeLog::OrderComplete",
          "Ddt::OrderChangeLog::OrderConfirm",
          "Ddt::OrderChangeLog::OrderPay",
          "Ddt::OrderChangeLog::OrderPlace",
          "Ddt::OrderChangeLog::AntiSettlement",
          "Ddt::OrderChangeLog::ChangeTable",
          "Ddt::OrderChangeLog::MergeTable",
          "Ddt::OrderChangeLog::AppendPayItem",
          "Ddt::OrderChangeLog::DestroyPayItem",
          "Ddt::OrderChangeLog::ClearAppended",
          "Ddt::OrderChangeLog::OrderRefund",
          "Ddt::OrderChangeLog::ConsumeBill",
          "Ddt::OrderChangeLog::ForceClear",
          "Ddt::OrderChangeLog::PrivilegeDiscount",
          "Ddt::OrderChangeLog::PrivilegeReduction",
          "Ddt::OrderChangeLog::PrivilegeFree",
          "Ddt::OrderChangeLog::CancelPrivilegeDiscount",
          "Ddt::OrderChangeLog::CancelPrivilegeReduction",
          "Ddt::OrderChangeLog::CancelPrivilegeFree"
        ],  %W(加菜 退菜 转菜 订单取消 订单完成 订单确认 订单支付 初始下单 反结帐 换台 并台 追加支付条目 删除支付条目 清除调账 订单退款 拉消费单 强制清台 权限打折 权限减免 权限免单 取消权限打折 取消权限减免 取消权限免单)

      [:order_place, :order_confirm, :order_complete, :order_cancel, :order_pay, :append_itemable, :delete_itemable, :change_table, :merge_table, :move_itemable, :anti_settlement, :append_pay_item].each do |change_type|
        define_method "is_#{change_type}?" do
          self.type.demodulize.underscore.to_sym == change_type
        end
      end

      concerning :ChangeTable do
        def change_table_bill
          content = []
          content << "<CB>换台</CB>"
          content << "\n"
          content << "<CB>#{from_table.name_with_zone} --> #{to_table.name_with_zone}</CB>"
          content << "\n"
          content << "单  号: #{order.number}"
          content << "时  间: #{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
          content.join("\n")
        end

        def change_table_msg
          "换台消息: 订单(#{order.number})已从(桌台:#{from_table.name_with_zone}) 换到(桌台:#{to_table.name_with_zone})"
        end
      end

      concerning :MergeTable do
        def merge_table_bill
          content = []
          content << "\n"
          content << "<CB>并台</CB>"
          content << "<CB>#{from_table.name_with_zone} ==> #{to_table.name_with_zone}</CB>"
          content << "\n"
          merge_from_order = (order.id == from_order_id ? order : from_order)
          merge_to_order = (order.id == to_table_id ? order : to_order)
          content << "原单号: #{merge_from_order.number}"
          content << "现单号: #{merge_to_order.number}"
          content << "时  间: #{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
          content.join("\n")
        end

        def merge_table_msg
          merge_from_order = (order.id == from_order_id ? order : from_order)
          merge_to_order = (order.id == to_table_id ? order : to_order)
          "并台消息: 订单(#{merge_from_order.number}), 已从(桌台: #{from_table.name_with_zone}) 并到(桌台:#{to_table.name_with_zone}), 新订单号:#{merge_to_order.number}"
        end
      end

      concerning :MoveItemable do
        def move_itemable_bill
          content = []
          content << "\n"
          content << "<CB>转菜</CB>"
          content << "<CB>#{from_table.name_with_zone} ==> #{to_table.name_with_zone}</CB>"
          content << "\n"
          move_from_order = (order.id == from_order_id ? order : from_order)
          moved_line_items = move_from_order.line_items.by_log(self)
          moved_line_items.each do |moved_line_item|
            content << "#{moved_line_item.name} * #{moved_line_item.quantity}"
          end
          content << "时  间: #{self.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
          content.join("\n")
        end

        def move_itemable_msg
          move_from_order = (order.id == from_order_id ? order : from_order)
          moved_line_items = move_from_order.line_items.by_log(self)
          items_info = moved_line_items.map{|l| "#{l.name} * #{l.quantity}"}.join(",")
          "转菜: #{from_table.name_with_zone} => #{to_table.name_with_zone} #{items_info}"
        end
      end

      def info
        if is_change_table?
          "换台 #{from_table.name_with_zone} => #{to_table.name_with_zone}"
        elsif is_merge_table?
          "并台 #{from_table.name_with_zone} => #{to_table.name_with_zone}"
        elsif is_move_itemable?
          "转菜 #{from_table.name_with_zone} => #{to_table.name_with_zone}"
        end
      end

      private
      def set_operator_name
        case operator
        when Account
          self.operator_name = "工作人员: #{operator.name}"
        when BaseUser
          self.operator_name = "客人编号: #{operator.id}"
        end
      end
    end
  end
end
