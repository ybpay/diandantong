#encoding: utf-8
module Ddt
  module OrderFormat
    class Csv < Ddt::OrderFormat::Base
      def self.content(orders, options)
        if orders.blank?
          pay_methods = []
        else
          pay_methods = orders[0].shop.pay_methods.map(&:name)
        end
        system_keys = %W(订单编号 门店名称 下单来源 下单时间 订单状态 订单类型 联系方式 配送员 配送地址 配送时间 预订人信息 预定时间 桌台信息 预订备注 备注 累计下单数量 支付方式 支付状态)
        system_keys = system_keys +  %W(消费合计 运费 应收合计)
        system_keys = system_keys + pay_methods
        custom_keys = %W(点菜人 其他优惠 自定义表单)
        CSV.generate(options) do |csv|
          title = system_keys
          title = title + custom_keys
          csv << title
          orders.each do |order|
            csv_line = []
            system_keys.each do |key|
              item = order.info_items.detect{|info| info[:name] == key }
              csv_line << (item.present? ? item[:value] : "")
            end
            csv_line << (order.waiter.nil? ? "" : order.waiter.name)
            csv_line << order.adjustments.map{|adjustment| [adjustment.label, adjustment.amount].join(":")}.join("|")
            csv_line << order.form_contents.map{|form_content| [form_content.label, form_content.content].join(":")}.join("|")
            csv << csv_line
          end
        end
      end
    end
  end
end
