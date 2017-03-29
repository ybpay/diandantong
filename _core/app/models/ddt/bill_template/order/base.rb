module Ddt
  module BillTemplate
    module Order
      class Base < BillTemplate::Base
        attr_accessor :order, :printer, :order_change_log, :bill_operator, :event
        delegate :branch, :shop, to: :order
        delegate :print_setting, to: :branch
        delegate :number, :type_name, :item_total, :note, :item_count,
                :consume_amount, :tax_total, :discount_amount, :original_amount, :amount_for_pay,
                :place_type_name, :state_name, :cancel_reason, :type_name, :pay_method_name, :pay_item_state_name, :settle_account_name,
                to: :order
        # delivery
        delegate :shipment_total, to: :order
        # eat_in_hall
        delegate :table_name, :table_zone_name, :table_name_with_zone, :guest_num, :waiter_name, to: :order
        # fastfood
        delegate :food_number, to: :order
        # reservation
        delegate :reservation_customer_info, :reservation_time_info, :reservation_note, to: :order
        def initialize(order:nil, printer:nil, order_change_log:nil, bill_operator:nil, event:nil)
          @order = order
          @printer = printer
          @order_change_log = order_change_log
          @bill_operator = bill_operator
          @event = event
        end

        def self.virtual_order_of_branch(branch)
          line_item_1 = OpenStruct.new({
              :id => 1,
              :active? => true,
              :gift? => false,
              :is_combo_package? => false,
              :itemable_id => 1,
              :itemable_type => "Ddt::Variant",
              :product_name => "宫爆鸡丁",
              :name => "宫爆鸡丁",
              :note => '加辣',
              :quantity => 2,
              :active_quantity => 2,
              :price => 20.00,
              :subtotal => 40.00,
              :itemable => OpenStruct.new({itemable_id: 1, itemable_type: "Ddt::Variant"}),
              :created_at => 1.minute.ago,
              :name_with_note => "宫爆鸡丁[加辣]",
              :adjustment_total => 0,
              :subtotal_after_discount => 39
            })
          line_item_2 = OpenStruct.new({
              :id => 2,
              :active? => true,
              :gift? => false,
              :is_combo_package? => false,
              :itemable_id => 2,
              :itemable_type => "Ddt::Variant",
              :product_name => "鱼香茄子",
              :name => "鱼香茄子",
              :note => '不加辣',
              :quantity => 2,
              :subtract_quantity => 1,
              :active_quantity => 1,
              :price => 10.00,
              :subtotal => 10.00,
              :order_change_log_id => 2,
              :itemable => OpenStruct.new({itemable_id: 2, itemable_type: "Ddt::Variant"}),
              :adjustment_total => 0,
              :subtotal_after_discount => 9
            })
          line_item_3 = OpenStruct.new({
              :id => 3,
              :active? => false,
              :gift? => false,
              :is_combo_package? => false,
              :itemable_id => 2,
              :itemable_type => "Ddt::Variant",
              :product_name => "鱼香茄子",
              :name => "鱼香茄子",
              :note => '不加辣',
              :item_name => "鱼香茄子",
              :item_price => 10.00,
              :item_note => '不加辣',
              :item_quantity => 1,
              :line_item_id => 3,
              :quantity => 1,
              :is_subtract? => true,
              :subtract_reason => "点错了",
              :price => 10.00,
              :subtotal => 10.00,
              :order_change_log_id => 3,
              :itemable => OpenStruct.new({itemable_id: 2, itemable_type: "Ddt::Variant"}),
              :adjustment_total => 0,
              :subtotal_after_discount => 9
            })
          order = OpenStruct.new({
            branch: branch,
            shop: branch.shop,
            number: "B12016020112000001",
            :is_eat_in_hall? => true,
            :is_FromWebpos? => false,
            type_str: 'eat_in_hall',
            table_name: "A01",
            table_zone_name: "大厅",
            table_name_with_zone: "大厅-A01",
            guest_num: 2,
            waiter_name: "服务员A",
            note: '备注',
            item_total: 60.00,
            consume_amount: 60.00,
            tax_total: 0.00,
            original_amount: 50.00,
            discount_amount: -10.00,
            amount_for_pay: 50.00,
            item_count: 3,
            line_items: OrderService::Collection::LineItems.new([line_item_1, line_item_2, line_item_3]),
            reload_line_item_trace_points: nil,
            placed_at: 30.minute.ago,
            place_type_name: '来自微信',
            state_name: '已确认',
            type_name: '堂点订单',
            pay_method_name: '现金',
            pay_item_state_name: '未支付',
            paid_at: 5.minute.ago,
            settle_account_name: '收银员B',
            vip_card_no: "1001",
            vip_card_amount: 100.0,
            moling_amount: 0.2,
            tick_account: "ddt"
          })
          litp_1 = OpenStruct.new(order: order, line_item_id: 1, :is_pending? => true, name: "宫爆鸡丁", note: '加辣', line_item_price: 20.00)
          litp_2 = OpenStruct.new(order: order, line_item_id: 1, :is_pending? => true, name: "宫爆鸡丁", note: '加辣', line_item_price: 20.00)
          litp_3 = OpenStruct.new(order: order, line_item_id: 2, :is_pending? => true, name: "鱼香茄子", note: '不加辣', line_item_price: 10.00)
          litp_4 = OpenStruct.new(order: order, line_item_id: 2, :is_pending? => true, name: "鱼香茄子", note: '不加辣', line_item_price: 10.00)
          form_content = OpenStruct.new(label: "自定义表单", content: "自定义表单内容")
          adjustment = OpenStruct.new(label: "优惠", amount: -10.00)
          pay_item = OpenStruct.new(name_sym: :pay_on_face, pay_method_name: "现金", amount_label: "￥50.00")
          order_change_log_1 = OpenStruct.new(id: 2, type: "Ddt::OrderChangeLog::AppendItemable", created_at: Time.now, operator_name: '服务员A', description: "加菜备注")
          order_change_log_2 = OpenStruct.new(id: 3, type: "Ddt::OrderChangeLog::DeleteItemable", created_at: Time.now, operator_name: '服务员A')
          order.line_item_trace_points = OrderService::Collection::LineItemTracePoints.new([litp_1, litp_2, litp_3, litp_4])
          order.form_contents = OrderService::Collection::FormContents.new([form_content])
          order.adjustments = OrderService::Collection::Adjustments.new([adjustment])
          order.pay_items = OrderService::Collection::PayItems.new([pay_item])
          order.order_change_logs = OrderService::Collection::OrderChangeLogs.new([order_change_log_1, order_change_log_2])
          order
        end

        def self.preview(branch)
          printer = Printer::Normal.new(print_spec: "58", use_scene: :webpos)
          order = virtual_order_of_branch(branch)
          result = self.new(order: order, printer: printer).render
          Array === result ? result.first : result
        end

        private
        def grouped_litps(order_change_log=nil)
          order.reload_line_item_trace_points
          if order_change_log.present?
            line_items = order.line_items.by_log(order_change_log)
            line_item_ids = line_items.map(&:id)
            litps = order.line_item_trace_points.select{|litp| line_item_ids.include?(litp.line_item_id)}
            unless printer.is_print_all
              litps = litps.select{|litp| litp.in_white_list?(printer.white_list_ids)}
            end
          else
            litps = order.line_item_trace_points.pending
            unless printer.is_print_all
              litps = litps.select{|litp| litp.in_white_list?(printer.white_list_ids)}
            end
          end
          litps.group_by{|litp| [litp.line_item_id, litp.name]}.map do |key, litps|
            litp = litps.first
            item = OpenStruct.new({
              line_item_id: key[0],
              item_name: key[1],
              item_note: litp.note,
              item_price: litp.line_item_price, # 如果是套餐, 这里是整个套餐的价格
              item_quantity: litps.count,
              item_subtotal: litp.line_item_price * litps.count,
              :is_combo_package? => false,
            })
            TagItem.new(item)
          end
        end

        def replace_if_tag(text, item=nil)
          replaced_text = text
          if_tags = TagHelper.scan_tag(text, "if")
          if_tags.each do |tag|
            replaced_text = replaced_text.sub(tag.body, tag.render(order, item))
          end
          replaced_text
        end

        def placed_at
          order.placed_at.strftime('%F %T')
        end

        def paid_at
          order.paid_at.try(:strftime, '%F %T')
        end

        def vip_info
          vip = order.vip_info
          if vip.present?
            "#{vip.vip_no}#{vip.name.present? ? "(#{vip.name})" : ''}"
          end
        end

        def branch_name
          branch.name
        end

        def user_placed_orders_count
          if order.user.present?
            order.user.vip_info.placed_orders_count
          end
        end

        def bill_operator_name
          bill_operator.try(:name)
        end

        def print_times
          "该类型票据不支持打印次数"
        end

        [:consume_amount, :tax_total, :original_amount, :discount_amount, :amount_for_pay, :moling_amount].each do |amount_method|
          define_method amount_method do
            order.send(amount_method).round(2)
          end
        end

        def form_contents
          order.form_contents.map{|form_content| "#{form_content.label}: #{form_content.content}"}.join("\n")
        end

        def adjustments
          order.adjustments.active.map{|adjustment| "#{adjustment.label}: #{adjustment.amount}"}.join("\n")
        end

        def pay_items
          order.pay_items.map do |pay_item|
            info = "#{pay_item.pay_method_name}: #{pay_item.amount_label}"
            if pay_item.name_sym.try(:to_sym) == :vip_card_pay
              vip_info = order.vip_info
              if vip_info.present?
                info << "\n卡内余额: #{vip_info.card_wallet.amount_in_currency}"
              end
            end
            info
          end.join("\n")
        end

        def base_order_inline_value_names
          [ :number, :type_name, :item_total, :note, :placed_at, :paid_at, :branch_name, :item_count,
            :consume_amount, :tax_total, :original_amount, :discount_amount, :amount_for_pay,
            :place_type_name, :state_name, :cancel_reason, :type_name, :pay_method_name, :pay_item_state_name,
            :form_contents, :adjustments, :pay_items,
            :vip_info, :user_placed_orders_count,
            :joke, :qrcode, :pcn_qrcode, :order_qrcode, :open_cashbox, :bill_operator_name, :settle_account_name,
            :vip_card_no, :vip_card_amount, :moling_amount, :tick_account, :subtract_reason, :print_times
          ]
        end

        def vip_card_no
          order.vip_card_no
        end

        def vip_card_amount
          order.vip_card_amount
        end

        def tick_account
          order.tick_account.try(:name)
        end
        #delivery
        def delivery_contact_info
          "#{order.delivery_name}-#{order.delivery_phone}"
        end

        def delivery_address_info
          delivery_zone_name = order.delivery_zone_name
          delivery_zone_str = delivery_zone_name.blank? ? "" : "[#{delivery_zone_name}]"
          "#{delivery_zone_str} #{order.delivery_address}"
        end

        def delivery_datetime
          "#{order.delivery_date.strftime("%F") rescue ""} #{order.delivery_time_display}"
        end

        def delivery_distance
          "#{order.distance.round(2)}公里"
        end

        def delivery_man_info
          delivery_man = order.shipment.delivery_man
          "#{delivery_man.name} #{delivery_man.phone}" if delivery_man.present?
        end

        def subtract_reason
          order.line_items.detect{|i| i.order_change_log_id == order_change_log.id}.subtract_reason
        end


        def order_inline_value_names
          case order.type_str.to_sym
          when :delivery
            [:shipment_total, :delivery_contact_info, :delivery_address_info, :delivery_datetime, :delivery_distance, :delivery_man_info]
          when :eat_in_hall
            [:table_name, :table_zone_name, :table_name_with_zone, :guest_num, :waiter_name]
          when :fastfood
            [:food_number]
          when :reservation
            [:reservation_customer_info, :reservation_time_info, :reservation_note]
          when :groupon, :recharge, :payment
            []
          end
        end

        def inline_value_names
          base_inline_value_names +
          base_order_inline_value_names +
          order_inline_value_names
        end

        def inline_item_value_names
          [
            :item_name,
            :item_note,
            :item_quantity,
            :item_price,
          ]
        end

        def replace_item_default(text)
          replace_text =
            case bill_width
            when 32
              "<item-name width=20 align='left'/><item-quantity width=3 align='right'/> <item-subtotal width=7 scale=2 align='right'/> "
            when 40
              "<item-name width=26 align='left'/><item-quantity width=3 align='right'/> <item-subtotal width=9 scale=2 align='right'/> "
            end
          text.gsub("{{item_default_template}}", replace_text)
        end

        def joke
          joke_content = Joke.random
          "#{asterisk_line}\n#{joke_content}\n#{asterisk_line}"
        end

        def pcn_qrcode
          gonghao_open_id = shop.primary_wechat_account.try(:gonghao_open_id)
          if gonghao_open_id.present?
            "<PCN>#{gonghao_open_id}</PCN>"
          end
        end
        alias_method :qrcode, :pcn_qrcode

        def order_qrcode
          gonghao_open_id = shop.primary_wechat_account.try(:gonghao_open_id)
          if gonghao_open_id.present?
            if printer.is_feie? || printer.is_fengchi?
              "微信扫描二维码关注订单进展、支付\n<QR>#{order.weixin_bind_url}</QR>"
            else
              "<QRI>#{order.bind_qr_code_image}</QRI>\n微信扫描二维码关注订单进展、支付\n"
            end
          end
        end

        def open_cashbox
          if printer.is_feie? && (order.is_eat_in_hall? || order.is_FromWebpos?)
            # 钱箱弹出指令
            27.chr + 'p' + 7.chr
          end
        end

      end
    end
  end
end