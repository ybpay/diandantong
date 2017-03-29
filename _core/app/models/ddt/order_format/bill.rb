#encoding: utf-8
module Ddt
  module OrderFormat
    class Bill < Ddt::OrderFormat::Base
      attr_accessor :printer, :white_list_ids, :order_info, :is_paid_bill, :is_product_bill, :is_consume_bill, :is_reprint_bill, :is_last_append_product_bill, :line_items

      def initialize(order, options={})
        @order = order
        @line_items = order.line_items.active
        @order_info = order.order_info
        @printer = options[:printer] || Printer::Normal.new(print_spec: (options[:print_spec] || "58"), use_scene: (options[:use_scene] || :webpos) )
        @white_list_ids = @printer.white_list_product_ids
        @is_paid_bill = options[:is_paid_bill]
        @is_product_bill = options[:is_product_bill]
        @is_consume_bill = options[:is_consume_bill]
        @is_reprint_bill = options[:is_reprint_bill]
        @is_last_append_product_bill = options[:is_last_append_product_bill]
        @is_money_display = options[:is_money_display]
      end

      def content
        return if !printer.concern_table(order)
        return if !printer.concern_line_item(@line_items)

        if printer.use_scene.to_sym == :label
          available_items_by_litp.map{|item| generate_label_bills(item)}.flatten
        elsif printer.print_per_product?
          available_items_by_litp.map{|item| generate_per_product_bill(item)}.flatten
        elsif printer.print_one_by_one?
          available_items_by_litp.map{|item| generate_bills(item) }.flatten
        else
          if printer.is_webpos?
            if is_product_bill
              generate_product_bill
            elsif is_consume_bill
              generate_consume_bill
            elsif is_last_append_product_bill
              generate_last_append_product_bill
            else
              generate_bill
            end
          else
            # 厨房打印机
            generate_short_bill
          end

        end
      end

      def self.align_center(text, width)
        return " "*((width-text.width)/2) + text
      end

      private


      def generate_bill
        bill = []
        bill << "<CM>结账单</CM>\n\n" if is_paid_bill
        bill << "<CM>补打</CM>\n\n" if is_reprint_bill
        bill << print_setting.page_header if print_setting.page_header.present?
        bill << order_info[:base_info].map(&format_info).join("\n")
        bill << order_info[:addition_info].map(&format_info).join("\n")
        if order_info[:line_item_info].size > 0
          bill << order_item_title
          bill << hyphen_line
          if is_paid_bill
            items = available_items_by_line_item(merge_itemable: true)
          else
            items = available_items_by_line_item
          end
          items.each do |item|
            if item[:itemable_type] == 'Ddt::ComboPackage'
              combo_package = Ddt::ComboPackage.find item[:itemable_id]
              lines = format_combo_package(combo_package, item)
              lines.each{|line| bill << line}
            else
              bill << format_order_item(item, nil, false)
            end
          end
          bill << hyphen_line
        end
        bill << order_info[:pay_info].map(&format_info).join("\n")
        bill << print_setting.page_footer if print_setting.page_footer.present?
        bill << joke
        bill << qrcode
        bill << "\n"
        bill << (27.chr + 'p' + 7.chr) if printer.is_feie? && (order.is_eat_in_hall? || order.is_FromWebpos?) # 钱箱弹出指令
        bill.compact.join("\n")
      end

      def generate_consume_bill
        bill = []
        bill << "\n"
        bill << print_setting.consume_bill_header if print_setting.consume_bill_header.present?
        bill << "<CM>客人就餐消费单</CM>\n"
        if order.is_eat_in_hall?
          bill << "<M>桌台:</M><B>#{order.table.try(:name_with_zone)}</B>"
        end
        bill << hyphen_line
        bill << "单号: #{order.number}"
        bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
        if order_info[:line_item_info].size > 0
          bill << order_item_title
          bill << hyphen_line
          available_items_by_line_item.each do |item|
            if item[:itemable_type] == 'Ddt::ComboPackage'
              combo_package = Ddt::ComboPackage.find item[:itemable_id]
              lines = format_combo_package(combo_package, item)
              lines.each{|line| bill << line}
            else
              bill << format_order_item(item, nil, false)
            end
          end
          bill << hyphen_line
        end
        bill << order_info[:pay_info].map(&format_info).join("\n")
        bill << qrcode
        bill << "\n"
        bill << print_setting.consume_bill_footer if print_setting.consume_bill_footer.present?
        bill << "\n\n\n"
        bill.compact.join("\n")
      end

      def generate_product_bill
        bill = []
        bill << print_setting.product_bill_header if print_setting.product_bill_header.present?
        bill << "<CM>点菜清单</CM>\n"
        if order.is_eat_in_hall?
          bill << "<M>桌台:</M><B>#{order.table.try(:name_with_zone)}</B>"
        end
        bill << hyphen_line
        bill << "单号: #{order.number}"
        if order.is_eat_in_hall? && order.guest_num.present?
          bill << "人数: #{order.guest_num}"
        end
        bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
        if order_info[:line_item_info].size > 0
          bill << order_item_title(@is_money_display)
          bill << hyphen_line
          available_items_by_line_item.each do |item|
            if item[:itemable_type] == 'Ddt::ComboPackage'
              combo_package = Ddt::ComboPackage.find item[:itemable_id]
              lines = format_combo_package(combo_package, item , @is_money_display)
              lines.each{|line| bill << line}
            else
              bill << format_order_item(item,nil,nil,@is_money_display)
            end
          end
          bill << hyphen_line
        end
        bill << "合计: #{order.amount_for_pay.round(2)}" if @is_money_display
        bill << "\n"
        bill << print_setting.product_bill_footer if print_setting.product_bill_footer.present?
        bill << "\n\n"
        bill.compact.join("\n")
      end

      def generate_last_append_product_bill
        bill = []
        bill << "<CM>最新一次加菜清单</CM>\n"
        if order.is_eat_in_hall?
          bill << "<M>桌台:</M><B>#{order.table_name_with_zone}</B>"
        end
        bill << hyphen_line
        bill << "单号: #{order.number}"
        if order.is_eat_in_hall? && order.guest_num.present?
          bill << "人数: #{order.guest_num}"
        end
        bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
        last_append_itemable_log = order.order_change_logs.append_itemable.last
        if last_append_itemable_log.present?
          @line_items = order.line_items.active.by_log(last_append_itemable_log)
          bill << order_item_title(@is_money_display)
          bill << hyphen_line
          available_items_by_line_item.each do |item|
            if item[:itemable_type] == 'Ddt::ComboPackage'
              combo_package = Ddt::ComboPackage.find item[:itemable_id]
              lines = format_combo_package(combo_package, item, @is_money_display)
              lines.each{|line| bill << line}
            else
              bill << format_order_item(item,nil,nil,@is_money_display)
            end
          end
          bill << hyphen_line
        end
        sum_total = available_items_by_line_item.sum {|line_item| line_item[:total]}
        bill << "合计: #{sum_total.round(2)}" if @is_money_display
        bill << "\n"
        bill << print_setting.product_bill_footer if print_setting.product_bill_footer.present?
        bill << "\n\n"
        bill.compact.join("\n")
      end

      def generate_per_product_bill(order_item)
        n = order_item[:quantity].to_i
        bills = []
        bill = []
        bill << "订单编号: #{order.number}"
        bill << "订单类型: #{order.type_name}"
        bill << order.short_addition_info.map(&format_info).join("\n")
        bill << "<M>名称:</M> <B>#{order_item[:name]}</B>"
        bill << "<M>数量:</M> <B>#{n}</B>"
        bill << "<M>品注:</M> <B>#{order_item[:note]}</B>" if order_item[:note].present?
        bill << "\n"
        bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
        bill << "下单时间: #{order.placed_at.try(:strftime, '%F %T')}"
        bill << "流水号: P#{order_item[:line_item_id]}"
        bills << bill.join("\n")
        bills
      end

      def generate_bills(order_item)
        n = order_item[:quantity].to_i
        bills = []
        n.times do |i|
          bill = []
          bill << "订单编号: #{order.number}"
          bill << "订单类型: #{order.type_name}"
          bill << order.short_addition_info.map(&format_info).join("\n")
          bill << "<M>名称:</M> <B>#{order_item[:name]}</B>"
          bill << "<M>数量:</M> <B>1</B>"
          bill << "<M>品注:</M> <B>#{order_item[:note]}</B>" if order_item[:note].present?
          bill << "\n"
          bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
          bill << "下单时间: #{order.placed_at.try(:strftime, '%F %T')}"
          bill << "流水号: I#{order_item[:line_item_id]}#{i}"
          bills << bill.join("\n")
        end
        bills
      end

      def generate_short_bill
        bill = []
        bill << "订单编号: #{order.number}"
        bill << "订单类型: #{order.type_name}"
        bill << "点菜员: #{order.waiter.name}" if order.waiter.present?
        bill << order.short_addition_info.map(&format_info).join("\n")
        available_items_by_litp.each do |item|
          bill << format_litp(item)
        end
        bill << "\n"
        bill.compact.join("\n")
      end

      def generate_label_bills(order_item)
        n = order_item[:quantity].to_i
        bills = []
        n.times do |i|
          bill = []
          bill << "\n#{order_item[:name]}"
          bill << order_item[:note] if order_item[:note].present?
          bill << "备注: #{order.note}" if order.note.present?
          bill << "桌号: #{order.table.name_with_zone} 价格: #{order_item[:price]}" if order.is_eat_in_hall?
          bill << "牌号: #{order.food_number} 价格: #{order_item[:price]}" if order.is_fastfood?
          bill << "单号: #{order.number}"
          bill << "#{order.placed_at.try(:strftime, '%F %T')}"
          bills << bill.join("\n")
        end
        bills
      end

      def available_items_by_line_item(merge_itemable: false)
        if printer.is_print_all?
          line_items = @line_items
        else
          line_items = @line_items.select{ |line_item| line_item.in_white_list?(white_list_ids)}
        end
        result = []
        counted = []
        line_items.each do |line_item|

          identifier = [line_item.itemable_type, line_item.itemable_id]
          if merge_itemable && counted.include?(identifier)
            index = counted.index identifier
            result[index][:quantity] += line_item.active_quantity
            result[index][:price] += line_item.price
            result[index][:total] += line_item.total
            result[index][:adjustment_total] += line_item.adjustment_total
            next
          end

          item = {
            id:        line_item.id,
            name:      line_item.name_with_note,
            price:     line_item.price,
            unit_name: line_item.unit_name,
            quantity:  line_item.active_quantity,
            total:     line_item.total,
            itemable_type: line_item.itemable_type,
            itemable_id: line_item.itemable_id
          }

          if 'Ddt::ComboPackage' == line_item.itemable_type
            result.unshift item
            counted.unshift identifier
          else
            result << item
            counted << identifier
          end
        end
        result
      end

      def available_items_by_litp
        if printer.is_print_all
          litps = order.line_item_trace_points.includes(:line_item).not_canceled
        else
          litps = order.line_item_trace_points.includes(:line_item).not_canceled.select{|litp| litp.in_white_list?(white_list_ids)}
        end
        litps = litps.to_a
        counted = []
        litps.map do |litp|
          # 套餐拆开来后， line_item_id 相同, 加上名字辨识
          identifier = [litp.line_item_id, litp.name]
          next if counted.include?(identifier)
          counted << identifier
          {
            line_item_id: litp.line_item_id,
            name: litp.name,
            note: litp.note,
            price: litp.line_item.price, # 如果是套餐, 这里是整个套餐的价格
            quantity: litps.count{|item| identifier == [item.line_item_id, item.name] }
          }
        end.compact
      end

      def order_item_title(is_money_display=true)
        if printer.is_normal?
          if printer.print_spec.to_s == '58'
            if is_money_display
              # 32 = 4*2 + 12 + 2*2 + 4 + 2*2
              "商品名称            数量    小计"
            else
              "商品名称            数量"
            end
          else
            if is_money_display
              # 40 = 4*2 + 18 + 2*2 + 6 + 2*2
              "商品名称                  数量      小计"
            else
              "商品名称                  数量"
            end
          end
        else
          if is_money_display
            # 32 = 4*2 + 12 + 2*2 + 4 + 2*2
            "商品名称            数量    小计"
          else
            "商品名称            数量"
          end
        end
      end

      def format_combo_package(combo_package, item ,is_money_display = true)
        lines = []
        fake_order_item = item.merge({name: "#{combo_package.name}："})
        lines << format_order_item(fake_order_item , nil,nil,is_money_display)
        item_quantity = item[:quantity]
        combo_package.each_item do |variant, quantity|
          fake_order_item = {
            name:  "  ├" + variant.name_with_options_text_with_cache,
            price: variant.price,
            quantity: quantity * item_quantity,
            unit_name: variant.unit_name,
            total: nil
          }
          lines << format_order_item(fake_order_item ,nil,nil, is_money_display)
        end
        lines
      end

      def format_order_item(order_item, quantity = nil, preferred_big_line_item = nil, is_money_display = true)
        if preferred_big_line_item == true || preferred_big_line_item == false
          use_big_line_item = preferred_big_line_item
        else
          use_big_line_item = print_setting.preferred_big_line_item
        end

        name = order_item[:name]
        quantity ||= order_item[:quantity]
        price = order_item[:price].to_f.round(2)
        if order_item[:total].nil? || !is_money_display
          total = ""
        else
          total= order_item[:total].to_f.round(2)
        end

        unformat_values = [quantity, total]
        if total.blank?
          total_formater = "%-10s"
        end
        result = []
        name_array = []
        if printer.is_normal?
          if printer.print_spec.to_s == '58'
            if use_big_line_item
              # 32 = 20 + 4 + 8
              name_array = item_name_split(name, 19)
              result << "<M>#{format_string_with_escape(20, name_array[0])}%3d #{total_formater || '%7.2f'} </M>" % unformat_values
            else
              # 32 = 20 + 4 + 8
              name_array = item_name_split(name, 19)
              result << "#{format_string_with_escape(20, name_array[0])}%3d #{total_formater || '%7.2f'} " % unformat_values
            end
          else
            if use_big_line_item
              # 40 = 26 + 4 + 10
              name_array = item_name_split(name, 25)
              result << "<M>#{format_string_with_escape(26, name_array[0])}%3d #{total_formater || '%9.2f'} </M>" % unformat_values
            else
              # 40 = 26 + 4 + 10
              name_array = item_name_split(name, 25)
              result << "#{format_string_with_escape(26, name_array[0])}%3d #{total_formater || '%9.2f'} " % unformat_values
            end
          end
        else
          if use_big_line_item
            # 16 = 10 + 1 + 5
            name_array = item_name_split(name, 9)
            result << "<M>#{format_string_with_escape(10, name_array[0])}%1d #{total_formater || '%4.2f'}</M>" % unformat_values
          else
            # 32 = 20 + 4 + 8
            name_array = item_name_split(name, 20)
            result << "#{format_string_with_escape(20, name_array[0])}%4d #{total_formater || '%7.2f'}" % unformat_values
          end
        end
        if use_big_line_item
          result << name_array[1..-1].map{|n| "<M> #{n}</M>"}.join("\n") if name_array.size > 1
        else
          result << name_array[1..-1].map{|n| " #{n}"}.join("\n") if name_array.size > 1
        end
        result.join("\n")
      end

      def format_litp(litp, quantity = nil)
        quantity ||= litp[:quantity]
        txt = ""
        txt << "\n   <M>#{litp[:name]} * </M><B>#{quantity}</B>"
        txt << "(#{litp[:note]})" if litp[:note].present?
        txt
      end

      def joke
        if print_setting.is_show_joke? && printer.is_webpos?
          joke_content = Ddt::Joke.random
          [asterisk_line, joke_content, asterisk_line].join("\n") if joke_content.present?
        end
      end

      def qrcode
        if print_setting.qrcode_image_type.present? && printer.is_webpos?
          gonghao_open_id = shop.primary_wechat_account.try(:gonghao_open_id)
          if gonghao_open_id.present?
            if print_setting.is_pcn_qrcode?
              "<PCN>#{gonghao_open_id}</PCN>"
            elsif print_setting.is_order_qrcode?
              if printer.is_feie? || printer.is_fengchi?
                "微信扫描二维码关注订单进展、支付\n<QR>#{order.weixin_bind_url}</QR>"
              else
                "<QRI>#{order.bind_qr_code_image}</QRI>\n微信扫描二维码关注订单进展、支付\n"
              end
            end
          end
        end
      end

      def hyphen_line
        "－" * (bill_width/2)
      end

      def asterisk_line
        "*" * bill_width
      end

      # 打印小票的宽度，以一个英文字母(字体等宽)为单位(汉字宽度为2)
      def bill_width
        if printer.is_normal?
          printer.print_spec.to_s == '58' ? 32 : 40
        else
          32
        end
      end

      def format_info
        ->(item){ print_setting.try("preferred_big_#{item[:key]}") ? "<M>#{item[:name]}:</M><B>#{item[:value]}</B>" : "#{item[:name]}: #{item[:value]}"}
      end

    end
  end
end
