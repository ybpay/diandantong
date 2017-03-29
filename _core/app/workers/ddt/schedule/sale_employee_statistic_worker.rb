# encoding: utf-8
module Ddt
  module Schedule
    class SaleEmployeeStatisticWorker < Ddt::Schedule::Base
      def perform
        Ddt::SaleEmployee.all.each do |sale_employee|
          date = Date.yesterday
          subject = "[售后统计] #{sale_employee.name} #{date.strftime('%F')}"
          body = "维护的商户数统计\n"
          body += "#{sale_employee.shops.count}家"
          body = "维护的代理商数统计\n"
          body += "#{sale_employee.agents.count}家"
          body += "订单数统计\n"
          all_shop_ids = sale_employee.all_shop_ids
          all_order_counts = OrderService::Api::Statistic.order_quantity(query: { shop_id_in: all_shop_ids, placed_at_gteq: date.beginning_of_day, placed_at_lteq: date.end_of_day }, group_by: :shop_id)
          Ddt::Shop.find(all_shop_ids).inject({}){|h, s| h[s.id]=0;h;}.merge(all_order_counts).each do |shop_id, order_count|
            shop = Ddt::Shop.find(shop_id)
            body += "#{shop.name} #{order_count}\n"
          end
          all_order_count = OrderService::Api::Statistic.order_quantity(query: { shop_id_in: all_shop_ids, placed_at_gteq: date.beginning_of_day, placed_at_lteq: date.end_of_day })
          body += "总计： #{all_order_count}\n"
          body += "平均： #{all_order_count * 1.0 / all_shop_ids.count }\n" if all_shop_ids.count > 0
          StatisticMailer.notify(sale_employee.email, subject, body).deliver
        end
      end
    end
  end
end
