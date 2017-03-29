module Ddt
  module BillTemplate
    module Order
      module BaseChangeBill
        extend ActiveSupport::Concern
        included do
          def changed_at
            order_change_log.created_at.strftime("%F %T")
          end

          delegate :operator_name, to: :order_change_log

          def change_note
            order_change_log.description
          end

          def base_order_inline_value_names
            super + [:changed_at, :operator_name, :change_note]
          end

          def self.preview(branch)
            printer = Printer::Normal.new(print_spec: "58", use_scene: :webpos)
            order = virtual_order_of_branch(branch)
            if self.name.demodulize.start_with?("Append")
              log = order.order_change_logs.append_itemable.last
            elsif self.name.demodulize.start_with?("Subtract")
              log = order.order_change_logs.subtract_itemable.last
            end
            result = self.new(order: order, printer: printer, order_change_log: log).render
            Array === result ? result.first : result
          end

          def subtract_items
            @subtract_items ||= order.line_items.by_log(order_change_log).select{|line_item|
                printer.is_print_all || line_item.in_white_list?(printer.white_list_ids)
              }.map{|item| TagItem.new(item)}
          end
        end
      end
    end
  end
end