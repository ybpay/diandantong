#encoding: utf-8
module Ddt
  module FinanceStatistic
    class CombiT1  < ::Ddt::FinanceStatistic::Base

      hash_attrs({
                     门店: :branch_id
                 })


      def self.class_info
        {
          name: 'combi_t1',
          permit_params: [:start_time, :end_time],
          default_params: this_day,
          label: '经营指标汇总',
          sortable: true
        }
      end

      def initialize(options={})
        super
        @branch_id = ALL_BRANCH
      end

      def filters
        [
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        ["门店","消费总额","折扣金额","销售金额","抹零金额","非实收金额","实收金额","订单数","客人数","单均","人均","上座率","翻台率"]
      end

      def result
        return @result if @result.present?
        params   = {is_async: false, shop: shop, accessible_branches: accessible_branches, start_time: start_time, end_time: end_time, explicit_assign_time_range: true}
        sales_st = Ddt::BusinessStatistic::SalesByBranch.new(params.merge(search_by: :order_paid_at)).to_combi_result
        order_st = Ddt::OrdersStatistic::OrderCountByBranch.new(params).to_combi_result
        table_st = Ddt::TableStatistic::RockoverRateByMonth.new(params).to_combi_result

        moling_amount_hash = {}
        @shop.branches.pluck(:id).each do |branch_id|
          moling_amount = Ddt::OrderService::Api::Statistic.order_moling_amount(query: {
              branch_id_eq: branch_id,
              paid_at_gteq: start_time,
              paid_at_lteq: end_time
          })
          moling_amount_hash[branch_id] = moling_amount
        end
        moling_st = {moling_amount: moling_amount_hash}

        @result = combi(sales_st, order_st, table_st, moling_st)
      end
      cache_result

      def body
        result
      end

      def foot
        data = body
        return [[]] if data == [[]] || data.blank?
        num_data = data.map{|i| i[1..-5]}
        first = num_data.shift
        foot_row = first.zip(*num_data).map(&:sum).unshift('总计')
        4.times{ foot_row << ''}
        [foot_row]
      end

      def combi(sales_st, order_st, table_st, moling_st)
        return [[]] if sales_st.blank?
        r = []
        sales_st.each_pair do |k, item|
          # k is branch_id
          row = []
          row << item[:branch_name]
          row << ((order_st[k][:consume_total] - moling_st[:moling_amount][k]||0.0) rescue 0)
          row << (order_st[k][:adjustment_total] rescue 0)
          row << (order_st[k][:amount] rescue 0)
          row << (moling_st[:moling_amount][k]||0.0 rescue 0)
          row << item[:not_actual_amount]
          row << item[:actual_amount]
          row << (order_st[k][:count] rescue 0)
          row << (order_st[k][:guest_num] rescue 0)
          row << (order_st[k][:per_order_consume] rescue 0)
          row << (order_st[k][:per_guest_consume] rescue 0)
          row << (table_st[k][:seat_rate] rescue 0)
          row << (table_st[k][:rockover_rate] rescue 0)
          r << row
        end
        r
      end

    end
  end
end
