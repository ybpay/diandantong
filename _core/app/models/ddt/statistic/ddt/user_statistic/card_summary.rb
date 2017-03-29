#encoding: utf-8
module Ddt
  module UserStatistic
    class CardSummary < Ddt::UserStatistic::Base
      def self.class_info
        {
          name: 'card_summary',
          label: '储值合计',
          permit_params: [:start_time, :end_time],
          sortable: true
        }
      end

      def result
        @items ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :reason],
            accumulate_keys: [:amount, :cash_amount, :extra_amount]
        ) do |current_date, next_date, has_next|
          if (has_next)
            params = {st_time: current_date...next_date}
          else
            params = {st_time: current_date..next_date}
          end
          shop.wallet_logs.joins(:wallet)
          .select('branch_id, reason, sum(ddt_wallet_logs.amount) as amount, sum(ddt_wallet_logs.cash_amount) as cash_amount, sum(ddt_wallet_logs.extra_amount) as extra_amount')
          .where(ddt_wallets: {type: 'Ddt::UserCardWallet'}, reason: [:for_deduction, :for_deduction_cancel, :for_vip_card_pay, :for_rollback_vip_card_pay, :for_recharge, :for_recharge_refund_complete], ddt_wallet_logs: params)
          .group(:branch_id, :reason).map{|line_item|
            {
              branch_id:        line_item.branch_id,
              reason:           line_item.reason,
              amount:           line_item.amount,
              cash_amount:      line_item.cash_amount,
              extra_amount:     line_item.extra_amount
            }
          }
        end
        merge(@items)
      end

      cache_result

      def filters
        [
          filter_start_time,
          filter_end_time,
        ]
      end

      def title
        %W[门店 充值金额 消费金额 差额]
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr1 =[
          {name: '门店', th_attrs: {rowspan: '2'}},
          {name: '充值金额', th_attrs: {colspan: '3'}},
          {name: '消费金额', th_attrs: {colspan: '3'}},
          {name: '余额', th_attrs: {colspan: '3'}}
        ]
        tr2 = [
          {name: '合计'},
          {name: '实收'},
          {name: '赠送'},
          {name: '合计'},
          {name: '实收'},
          {name: '赠送'},
          {name: '合计'},
          {name: '实收'},
          {name: '赠送'}
        ]
        thead << tr1
        thead << tr2
        thead
      end

      def body
        content = []
        result.each_pair do |branch_id, v|
          row = []
          row << get_branch_name(branch_id, blank_label: '平台充值', noexist_label: '未知来源')
          row << v[:for_recharge]
          row << v[:for_recharge_cash_amount]
          row << v[:for_recharge_extra_amount]
          row << v[:for_consume]
          row << v[:for_consume_cash_amount]
          row << v[:for_consume_extra_amount]
          row << v[:for_recharge] - v[:for_consume]
          row << v[:for_recharge_cash_amount] - v[:for_consume_cash_amount]
          row << v[:for_recharge_extra_amount] - v[:for_consume_extra_amount]
          content << row
        end
        content
      end

      def foot
        datas = body
        return [] if datas.blank?
        first = datas.shift
        zip_data = first.zip(*datas)
        zip_data.shift
        foot_row = zip_data.map(&:sum).unshift('合计')
        [foot_row]
      end

      def merge(items)
        h = {}
        items.each do |item|
          h[item[:branch_id]] ||= {
            for_consume: 0,
            for_consume_cash_amount: 0,
            for_consume_extra_amount: 0,
            for_recharge: 0,
            for_recharge_cash_amount: 0,
            for_recharge_extra_amount: 0
          }

          reason =\
          case item[:reason].to_sym
          when :for_deduction, :for_deduction_cancel, :for_vip_card_pay, :for_rollback_vip_card_pay
            :for_consume
          when :for_recharge, :for_recharge_refund_complete
            :for_recharge
          end

          case item[:reason].to_sym
          when :for_deduction_cancel, :for_rollback_vip_card_pay
            amount       = - item[:amount]
            cash_amount  = -item[:cash_amount]
            extra_amount = -item[:extra_amount]
          when :for_recharge, :for_recharge_refund_complete
            amount       = item[:amount]
            cash_amount  = item[:cash_amount]
            extra_amount = item[:extra_amount]
          else
            amount       = item[:amount].abs
            cash_amount  = item[:cash_amount].abs
            extra_amount = item[:extra_amount].abs
            item[:amount].abs
          end
          h[item[:branch_id]][reason] += amount
          h[item[:branch_id]]["#{reason}_cash_amount".to_sym] += cash_amount
          h[item[:branch_id]]["#{reason}_extra_amount".to_sym] += extra_amount
        end
        h
      end

    end
  end
end
