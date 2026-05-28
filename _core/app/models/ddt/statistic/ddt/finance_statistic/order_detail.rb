#encoding: utf-8
module Ddt
  module FinanceStatistic
    class OrderDetail  < ::Ddt::FinanceStatistic::Base
      attr_accessor :branch_id, :records
      hash_attrs({
          门店: :branch_id
      })
      include Ddt::CacheModel
      cache_model 'Ddt::Account', with_discarded: true

      def self.class_info
        {
          name: 'order_detail',
          permit_params: [:branch_id, :start_time, :end_time],
          default_params: this_day,
          label: '营业账单明细表',
          warning: '该表最大支持31天的数据查询, 大于31天将返回空结果',
          # paginate: true,
          sortable: true
        }
      end

      def initialize(options={})
        super
        # @is_async = false
        @branch_id = options[:branch_id]
      end

      def filters
        [
          filter_branch(support_all: false, support_abstract: false),
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        ["门店","订单号","类型","桌台信息","结算人","下单时间","结算时间","消费金额","实收金额"] + shop.pay_methods.enable.map(&:name)
      end

      def record2row(record)
        row = []
        row << get_branch_name(record.branch_id)
        row << record.number
        row << record.type_name
        row << record.try(:table_name_with_zone)
        row << get_account(record.settle_account_id).try(:name)
        row << record.placed_at.try(:strftime, "%F %T")
        row << record.paid_at.try(:strftime, "%F %T")
        row << record.total
        row << record.pay_items.actual_amount
        @pay_methods ||= shop.pay_methods.enable.all
        @pay_methods.each do |pay_method|
          pay_item = record.pay_items.detect{|pay_item| pay_item.pay_method_id == pay_method.id }
          row << pay_item.try(:amount)
        end
        row
      end

      def result
        params   = {
            shop_id: shop.id,
            branch_id: @branch_id,
            # paid_at: start_time..end_time,
            type: ["Ddt::EatInHallOrder", "Ddt::DeliveryOrder", "Ddt::FastfoodOrder", "Ddt::PaymentOrder"]
        }

        pay_methods = shop.pay_methods.enable.all
        @records ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            concat: true
        ) do |current_date, next_date, has_next|
          if has_next
            q = params.merge(paid_at_gteq:  current_date, paid_at_lt: next_date)
          else
            q = params.merge(paid_at_gteq:  current_date, paid_at_lteq: next_date)
          end

          Ddt::OrderService::Orders.completed.includes(:pay_items).where(q).query.map do |order|
            row = [
                order.branch_id,
                order.number,
                order.type_name,
                order.try(:table_name_with_zone),
                get_account(order.settle_account_id).try(:name),
                order.placed_at.try(:strftime, "%F %T"),
                order.paid_at.try(:strftime, "%F %T"),
                order.total,
                order.pay_items.actual_amount
            ]
            pay_methods.each do |pay_method|
              pay_item = order.pay_items.detect{|pay_item| pay_item.pay_method_id == pay_method.id }
              row << pay_item.try(:amount)
            end
            row
          end
        end

      end

      cache_result

      def body
        return @body if @body.present?
        @body = result
      end

      def foot
        data = body
        return [[]] if data.blank?
        foot_row = ["总计", data.count, "", "", "", "", "" ]
        length = 8 + shop.pay_methods.enable.count
        7.upto(length) do |index|
          foot_row[index] = data.map{|data_row| data_row[index].to_f }.sum.round(2)
        end
        [foot_row]
      end
    end
  end
end
