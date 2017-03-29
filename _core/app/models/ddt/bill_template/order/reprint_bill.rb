module Ddt
  module BillTemplate
    module Order
      class ReprintBill < BillTemplate::Order::Base
        def render
          template = template_from_setting
          order_content = get_order_content
          if order_content.present?
            if order_content.is_a? Array
              order_content.map do |content|
                output = template.gsub("{{order_content}}", content)
                output = replace_inline_values(output, inline_value_names)
                output
              end
            else
              output = template.gsub("{{order_content}}", order_content)
              output = replace_inline_values(output, inline_value_names)
              output
            end
          end
        end
        alias_method_chain :render, :error_catch

        def self.preview(branch)
          printer = Printer::Normal.new(print_spec: "58", use_scene: :webpos)
          order = virtual_order_of_branch(branch)
          event = OpenStruct.new({
            track_from: "FromWebpos",
            created_at: Time.now,
            note: "补打备注",
            operator_name: "服务员A"
          })
          self.new(order: order, printer: printer, event: event).render
        end

        def self.default_template
          <<-TMP.strip_heredoc
            <CB>补打</CB>
            {{order_content}}
            补打时间: {{event_created_at}}
            备注: {{event_note}}
            补打人: {{event_operator_name}}
          TMP
        end

        private
        def get_order_content
          line_items = order.line_items.active
          return unless printer.concern_table(order)
          return unless printer.concern_line_item(line_items)
          if printer.is_label?
            BillTemplate::Order::LabelBill.new(order: order, printer: printer, bill_operator: bill_operator).render
          elsif printer.print_per_product?
            BillTemplate::Order::PerProductBill.new(order: order, printer: printer, bill_operator: bill_operator).render
          elsif printer.print_one_by_one?
            BillTemplate::Order::OneByOneBill.new(order: order, printer: printer, bill_operator: bill_operator).render
          elsif printer.is_webpos?
            BillTemplate::Order::Bill.new(order: order, printer: printer, bill_operator: bill_operator).render
          elsif printer.is_guest?
            BillTemplate::Order::ProductBill.new(order: order, printer: printer, bill_operator: bill_operator).render
          elsif printer.is_kitchen?
            BillTemplate::Order::ShortBill.new(order: order, printer: printer, bill_operator: bill_operator).render
          end
        end

        def event_created_at
          event.created_at_str
        end

        def event_note
          event.note
        end

        def event_operator_name
          event.operator_name
        end

        def inline_value_names
          super + [:event_created_at, :event_note, :event_operator_name]
        end

      end
    end
  end
end
