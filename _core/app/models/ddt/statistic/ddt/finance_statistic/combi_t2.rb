#encoding: utf-8
module Ddt
  module FinanceStatistic
    class CombiT2  < ::Ddt::FinanceStatistic::Base

      hash_attrs({
        门店: :branch_id
      })


      def self.class_info
        {
          name: 'combi_t2',
          permit_params: [:start_time, :end_time],
          default_params: this_day,
          label: '综合结算汇总',
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

      def result
        return @result if @result.present?
        params   = {is_async: false, shop: shop, accessible_branches: accessible_branches, start_time: start_time, end_time: end_time, explicit_assign_time_range: true}
        @recharge_st = Ddt::BusinessStatistic::RechargeSettleSummary.new(params.merge(search_by: :shift_opened_at, ignore_empty_data: true)).to_combi_result
        @sales_st    = Ddt::BusinessStatistic::SalesByMonth.new(params.merge(search_by: :shift_opened_at, ignore_empty_data: true)).to_combi_result
        @adjustment_st = Ddt::BusinessStatistic::Promotion.new(params).to_combi_result
        @moling_amount = Ddt::OrderService::Api::Statistic.order_moling_amount(
            {
              query:{
                shop_id_eq: shop.id,
                pay_item_state_eq: :paid,
                paid_at_gteq: start_time,
                paid_at_lteq: end_time
              }
            }
          )

        @result = combi(@sales_st, @recharge_st)
      end
      cache_result

      def title
        ['科目代码', '科目名称', '营业额', '实收', '非实收', '储值', '合计']
      end

      def body
        result
      end

      def foot
        items = result
        adjustment_total = (@adjustment_st.values.map{|v| v[:adjustment]}.sum || 0)

        row1 = []
        row1 << ''
        row1 << '折扣'
        row1 << ''
        row1 << ''
        row1 << adjustment_total
        row1 << ''
        row1 << ''

        row2 = []
        row2 << ''
        row2 << '抹零'
        row2 << ''
        row2 << ''
        row2 << @moling_amount
        row2 << ''
        row2 << ''

        row3 = []
        row3 << ''
        row3 << '总计'
        row3 << items.map{|item| item[2]}.sum
        row3 << items.map{|item| item[3]}.sum
        row3 << (items.map{|item| item[4]}.sum || 0)
        row3 << items.map{|item| item[5]}.sum
        row3 << items.map{|item| item[6]}.sum

        [row1, row2, row3]
      end

      def combi(sales_st, recharge_st)
        return [[]] if sales_st.blank?
        r = []
        sales_st.each_pair do |k, item|
          # k is pay_method_id
          recharge_amount = (recharge_st[k][:actual_amount] rescue 0)
          row = []
          row << item[:pay_method_code]
          row << item[:pay_method_name]
          row << item[:amount]
          row << item[:actual_amount]
          row << item[:not_actual_amount]
          row << recharge_amount
          row << item[:amount] + recharge_amount
          r << row
        end
        r
      end

    end
  end
end
