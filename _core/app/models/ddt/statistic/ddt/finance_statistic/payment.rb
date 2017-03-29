# encoding: utf-8
module Ddt
  module FinanceStatistic
    # 在线支付分析
    class Payment  < ::Ddt::FinanceStatistic::Base
      attr_accessor :branch_id, :workflow_state, :payment_method_id
      hash_attrs({
        门店: :branch_id,
        支付状态: :workflow_state,
        支付方式: :payment_method_id
      })

      def self.class_info
        {
            name: 'payment',
            permit_params: [:branch_id, :start_time, :end_time, :workflow_state, :payment_method_id],
            default_params: this_day,
            label: '在线支付明细表',
            sortable: true
        }
      end

      def initialize(options={})
        super
        @branch_id = options[:branch_id]
        @workflow_state = options[:workflow_state]
        @payment_method_id = options[:payment_method_id]
      end

      def filters
        [
            filter_branch(support_all: true, support_abstract: false),
            filter_start_time,
            filter_end_time,
            filter_workflow_state,
            filter_payment_method_id
        ]
      end

      def filter_payment_method_id
        local_datas = shop.payment_methods.map do |payment_method|
          {
              id: payment_method.id,
              name: payment_method.name
          }
        end
        {name: 'payment_method_id', type: 'ddselect2', data: {useas: 'local_select', 'local-datas' => local_datas, single: true, placeholder: '支付方式'}}
      end

      def filter_workflow_state
        local_datas = []
        Ddt::Payment.workflow_state_collection_hash.each do |it|
          local_datas.push({
              id: it[:value],
              name: it[:name]
          })
        end
        {name: 'workflow_state', type: 'ddselect2', data: {useas: 'local_select', 'local-datas' => local_datas, single: true, placeholder: '状态'}}
      end

      def title
        %w(门店 订单号 金额 支付方式 状态 更新时间)
      end

      def result
        return @result if @result.present?
        params = {updated_at: start_time..end_time, workflow_state: @workflow_state, payment_method_id: @payment_method_id}
        if all_branch?
          @result = shop.payments.where(params)
        elsif one_branch?
          @result = shop.payments.where(params.merge(branch_id: @branch_id))
        else
          @result = Ddt::Payment.none
        end
      end
      cache_result

      def body
        return @body if @body.present?
        @body = result.map do |payment|
          row = []
          row << payment.branch.try(:name)
          row << payment.order.try(:number) rescue ''
          row << payment.amount
          row << payment.payment_method.name
          row << payment.workflow_state_name
          row << payment.updated_at
          row
        end
      end

      def foot
        data = body
        return [[]] if data.blank?
        foot_row = ["总计", data.count, "", "", "", "", "" ]
        length = foot_row.count
        foot_row[2] = data.map{|data_row| data_row[2].to_f }.sum.round(2)
        [foot_row]
      end

    end
  end
end
