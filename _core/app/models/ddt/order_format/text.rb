#encoding: utf-8
module Ddt
  module OrderFormat
    class Text < Ddt::OrderFormat::Base
      # ==== keys ====
      # :number
      # :branch_name
      # :place_type_name
      # :place_at
      # :state_name
      # :calcel_reason
      # :type_name
      # :pay_method_name
      # :pay_item_state_name
      # :vip_info
      # :note
      # :place_orders_count
      # :form_content
      # :delivery_contact
      # :delivery_address
      # :delivery_datetime
      # :delivery_distance
      # :delivery_man
      # :eat_in_hall_table_name
      # :eat_in_hall_guest_num
      # :eat_in_hall_waiter
      # :eat_in_hall_note
      # :reservation_customer_info
      # :reservation_time_info
      # :reservation_note
      # :adjustment
      # :shipment_total
      # :total


      def content(options={})
        version = options[:version]
        if version.present?
          event_type = options[:event_type]
          self.send "#{version}_#{event_type}"
        else
          lines = all_infos.map{|info| info[1]}
          lines.unshift("")
          lines.join("\n")
        end
      end

      # ===== 订单 =====
      def system_weixin_order_placed
        select_info(all_infos,
          [
            :number,
            :place_type_name,
            :state_name,
            :calcel_reason,
            :pay_method_name,
            :pay_item_state_name,
            :vip_info,
            :note,
            :place_orders_count,
            :form_content,
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :delivery_man,
            :eat_in_hall_table_name,
            :eat_in_hall_guest_num,
            :eat_in_hall_waiter,
            :eat_in_hall_note,
            :reservation_customer_info,
            :reservation_time_info,
            :reservation_note,
            :adjustment,
            :shipment_total

          ]
        )
      end

      def system_weixin_order_confirmed
        select_info(base_infos + pay_infos,
          [
            :place_type_name,
            :pay_method_name,
            :pay_item_state_name,
            :note,
            :form_content,
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :delivery_man,
            :eat_in_hall_table_name,
            :eat_in_hall_guest_num,
            :eat_in_hall_waiter,
            :eat_in_hall_note,
            :reservation_customer_info,
            :reservation_time_info,
            :reservation_note,
            :adjustment,
            :shipment_total
          ]
        )
      end

      def system_weixin_order_canceled
        select_info(line_item_infos + base_infos, [
          :place_type_name,
          :calcel_reason
        ])
      end

      def system_weixin_order_paid
        select_info(line_item_infos + base_infos + pay_infos,
          [
            :place_type_name,
            :state_name,
            :type_name,
            :pay_method_name,
            :pay_item_state_name,
            :vip_info,
            :place_orders_count,
            :adjustment,
            :shipment_total
          ]
        )
      end

      def system_weixin_order_hasten
        select_info(line_item_infos + base_infos,
          [
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :delivery_man,
            :eat_in_hall_table_name,
            :eat_in_hall_guest_num,
            :eat_in_hall_waiter,
            :eat_in_hall_note,
            :reservation_customer_info,
            :reservation_time_info,
            :reservation_note
          ]
        )
      end

      def system_weixin_order_call_waiter
        select_info(base_infos,
          [
            :eat_in_hall_table_name,
            :eat_in_hall_guest_num,
            :eat_in_hall_waiter,
            :eat_in_hall_note
          ]
        )
      end

      def weixin_order_placed
        select_info(all_infos,
          [
            :branch_name,
            :calcel_reason,
            :pay_method_name,
            :pay_item_state_name,
            :vip_info,
            :note,
            :form_content,
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :delivery_man,
            :eat_in_hall_table_name,
            :eat_in_hall_guest_num,
            :eat_in_hall_waiter,
            :eat_in_hall_note,
            :reservation_customer_info,
            :reservation_time_info,
            :reservation_note,
            :adjustment,
            :shipment_total,
            :total
          ]
        )
      end

      def weixin_order_started
        select_info(line_item_infos + base_infos,
          [
            :branch_name,
            :pay_method_name,
            :pay_item_state_name,
            :vip_info,
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :delivery_man,
            :adjustment,
            :shipment_total,
            :total
          ]
        )
      end

      def weixin_order_change_delete_itemable
        select_info(base_infos,
          [
            :branch_name,
            :place_at,
            :state_name,
            :vip_info,
            :note,
            :form_content,
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :delivery_man,
            :eat_in_hall_table_name,
            :eat_in_hall_guest_num,
            :eat_in_hall_waiter,
            :eat_in_hall_note,
            :reservation_customer_info,
            :reservation_time_info,
            :reservation_note
          ]
        )
      end

      [
        :weixin_order_confirmed,
        :weixin_order_canceled,
        :weixin_order_completed,
        :weixin_order_paid,
        :weixin_order_call_customer
      ].each do |name|
        define_method name do
          self.select_info(base_infos + pay_infos + line_item_infos,
            [
              :branch_name,
              :state_name,
              :calcel_reason,
              :pay_item_state_name
            ]
          )
        end
      end




      # ===== 配送 =====
      def system_weixin_shipment_assigned
        select_info(base_infos + pay_infos + line_item_infos,
          [
            :number,
            :branch_name,
            :delivery_contact,
            :delivery_address,
            :delivery_datetime,
            :delivery_distance,
            :adjustment,
            :shipment_total
          ]
        )
      end

      [
        :system_weixin_shipment_unassigned,
        :system_weixin_shipment_started,
        :system_weixin_shipment_shipped
      ].each do |name|
        define_method name do
          self.select_info(base_infos,
            [
              :number,
              :branch_name,
              :delivery_contact,
              :delivery_address,
              :delivery_datetime
            ]
          )
        end
      end

      [
        :weixin_shipment_assigned,
        :weixin_shipment_started,
        :weixin_shipment_shipped
      ].each do |name|
        define_method name do
          self.select_info(line_item_infos + base_infos,
            [
              :number,
              :branch_name,
              :delivery_contact,
              :delivery_address,
              :delivery_datetime,
              :delivery_distance,
              :delivery_man
            ]
          )
        end
      end

      # ===== 桌台 =====
      [
        :system_weixin_table_changed,
        :system_weixin_table_merged,
        :system_weixin_table_opened,
        :system_weixin_table_cleared,
        :system_weixin_table_move_itemable,
      ].each do |name|
        define_method name do
          self.select_info(base_infos,
            [
              :eat_in_hall_guest_num,
              :eat_in_hall_waiter
            ]
          )
        end
      end

        def all_infos
          base_infos + line_item_infos + pay_infos
        end

        def base_infos
          lines = []
          (order_info[:base_info] + order_info[:addition_info]).each do |info|
            lines << [true,"#{info[:name]}: #{info[:value]}",info[:key]]
          end
          lines
        end

        def pay_infos
          lines = []
          order_info[:pay_info].each do |info|
            lines << [true,"#{info[:name]}: #{info[:value]}",info[:key]]
          end
          lines
        end

        def line_item_infos
          lines = []
          return lines if order_info[:line_item_info].blank?
          lines << [false, "#{'商品名称'.fixed_width(14)}#{'单价'.fixed_width(6)}#{'数量'.fixed_width(6)}#{'小计'.fixed_width(6)}"]
          lines << [false, "－－－－－－－－－－－－－－－－"]
          order_info[:line_item_info].each do |item|
            lines << [false, "#{item[:name].fixed_width(14)}#{item[:price].to_s.ljust(9, ' ')}#{item[:quantity].to_s.ljust(3, ' ')}#{item[:total].to_s.rjust(9, ' ')}"]
          end
          lines
        end


        def order_info
          @order_info ||= order.order_info
        end

        def select_info(infos, keys)
          lines = [""]
          infos.each do |info|
            # can_filter info[0]
            # line_text  info[1]
            # filter_key info[2]
            lines << info[1] if !info[0] || keys.include?(info[2])
          end
          lines.join("\n")
        end

    end
  end
end
