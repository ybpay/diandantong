# encoding: utf-8
module Ddt
  module Schedule
    class CheckShopInactiveWorker < Ddt::Schedule::Base

      def perform
        now = Time.now
        month_ago = now - 30.days
        inactive_shops = []

        # 产生支付行为, shop 会更新
        # 一个月都未产生支付行为
        Ddt::Shop.where('expiration_time > :now and updated_at < :month_ago', now: now, month_ago: month_ago).find_each do |shop|
          inactive_shops << shop
        end


        # 平均每个门店每个月至少下单
        judge_order_count = 90
        Ddt::Shop.where('expiration_time > :now and updated_at > :month_ago', now: now, month_ago: month_ago).find_each do |shop|
          if Time.now - shop.expiration_time > 7.days
            shop_month_order_count = shop.orders.where(placed_at: month_ago..now).count
            if shop_month_order_count / shop.branches_count < judge_order_count
              inactive_shops << shop
            end
          end
        end

        send_email(inactive_shops)

      end

      private

      def send_email(shops)
        body = []
        sorted_shops = shops.sort do |a, b|
          return -1 if a.sale_employee_id.blank?
          return -1 if b.sale_employee_id.blank?
          a.sale_employee_id <=> b.sale_employee_id
        end
        sorted_shops.each do |shop|
          body << "售后: #{sale_employee_name(shop.sale_employee_id)}, 商铺: #{shop.name}, (ID: #{shop.id}, #{shop.address}, #{shop.phone})"
        end
        BaseMailer.notify(Rails.application.config.customer_service_group, "[不活跃商铺]", body.join("\n"))
      end

      def sale_employee_name(id)
        return "" if id.blank?
        @sale_employees ||= Ddt::SaleEmployee.all
        @sale_employees.detect{|s| s.id == id}
      end

    end
  end
end
