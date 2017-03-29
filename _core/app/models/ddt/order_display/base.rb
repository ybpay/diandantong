#encoding: utf-8
module Ddt
  module OrderDisplay
    class Base
      attr_accessor :order

      def initialize(order)
        @order = order
      end

      def order_info
        {
          base_info: base_info,
          addition_info: addition_info,
          line_item_info: line_item_info,
          pay_info: pay_info,
          pad_info: pad_info
        }
      end

      def info_items
        {
          base_info: base_info,
          addition_info: addition_info,
          pay_info: pay_info,
        }.values.flatten
      end

      def base_info
        info = [
          [:number             , '订单编号' , @order.number],
          [:branch_name        , '门店名称' , (@order.branch.name rescue @order.branch_id)],
          [:place_type_name    , '下单来源' , @order.place_type_name],
          [:place_at           , '下单时间' , @order.placed_at.try(:strftime , '%F %T')],
          [:state_name         , '订单状态' , @order.state_name],
          [:type_name          , '订单类型' , @order.type_name],
          [:pay_method_name    , '支付方式' , @order.pay_method_name],
          [:pay_item_state_name, '支付状态' , @order.pay_item_state_name]
        ]
        info << [:paid_at, '支付时间', @order.paid_at.try(:strftime , '%F %T')] if @order.paid_at.present?
        info.insert(5, [:calcel_reason, '取消原因', @order.cancel_reason]) if order.is_canceled?
        make_detail_desc(info)
      end

      # 在子类中添加额外信息
      def addition_info
        data = []
        vip_info = @order.vip_info
        data << [:vip_info, '会员信息', "#{vip_info.vip_no}#{vip_info.name.present? ? "(#{vip_info.name})":''}"] if vip_info.present?
        data << [:note, '备注', order.note]
        data << [:place_orders_count, '累计下单数量', order.user.placed_orders_count] if order.user.present?
        order.form_contents.map do |it|
          data << [:form_content, it.label, it.content]
        end
        make_detail_desc(data)
      end

      # 简短额外信息(现只用在厨房打印上)
      def short_addition_info
        data = []
        data << [:note, '备注', order.note] if order.note.present?
        order.form_contents.map do |it|
          data << [:form_content, it.label, it.content]
        end
        make_detail_desc(data)
      end

      def line_item_info
        order.line_items.active.map do |line_item|
          {
            id:        line_item.id,
            name:      line_item.name_with_note,
            price:     line_item.price,
            unit_name: line_item.unit_name,
            quantity:  line_item.active_quantity,
            total:     line_item.total
          }
        end
      end

      def pay_info
        data = []
        order.adjustments.active.each do |it|
          data << [:adjustment, it.label, it.amount]
        end
        data << [:shipment_total, '运费', order.shipment_total] if order.is_delivery?
        if order.paid?
          order.pay_items.each do |pay_item|
            data <<["pay_method_#{pay_item.pay_method_id}", pay_item.pay_method_name, pay_item.amount_label]
            if order.is_vip_card_pay?
              vip_info = order.vip_info
              if vip_info.present?
                data <<["vip_info_card_msg", '卡内余额', vip_info.card_wallet.amount_in_currency]
              end
            end
          end
        end
        data << [:consume_amount, '消费合计', order.consume_amount.round(2)]
        data << [:data, "税收合计", order.tax_total.round(2)] if order.tax_total != 0
        data << [:original_amount, '订单合计', order.original_amount.round(2)]
        data << [:discount_amount, '折扣合计', order.discount_amount.round(2)]
        data << [:total, '应收合计', order.amount_for_pay.round(2)]
        make_detail_desc(data)
      end

      def pad_info
        data = []
        # 仅堂点订单有
        if @order.is_eat_in_hall?
          data = data.concat [
                                 ['number', '订单编号', @order.number],
                                 ['place_at', '下单时间', @order.placed_at.try(:localtime).try(:strftime, '%F %T')],
                                 ['state_name', '订单状态', @order.state_name]
          ]

          vip_info = @order.vip_info
          data << [:vip_info, '会员信息', "#{vip_info.vip_no}#{vip_info.name.present? ? "(#{vip_info.name})":''}"] if vip_info.present?

          data = data.concat [
                                 ['pay_method_name', '支付方式', @order.pay_method_name],
                                 ['pay_state', '支付状态', @order.pay_item_state_name],
                                 ['total_in_currency', '点餐合计', @order.total_in_currency],
                                 ['table_name_with_zone', '座位信息', @order.table_name_with_zone],
                                 ['note', '备注', @order.note]
                             ]
        end
        make_detail_desc(data)
      end


      private
      def make_detail_desc(array)
        array.map {|it| {key: it[0], name: it[1], value: it[2]}}
      end
    end
  end
end
