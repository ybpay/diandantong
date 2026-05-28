#encoding: utf-8
module Ddt
  module UserStatistic
    class CardLog < Ddt::UserStatistic::Base
      attr_accessor :records, :vip_no, :vip_phone
      include Ddt::CacheModel
      cache_model 'Ddt::VipInfo', with_discarded: true
      hash_attrs({
          会员号: :vip_no,
          会员电话: :vip_phone
     })

      def self.class_info
        {
          name: 'card_log',
          label: '会员卡明细',
          permit_params: [:start_time, :end_time, :branch_id, :vip_no, :vip_phone],
          paginate: false
        }
      end

      def initialize(options={})
        super
        @vip_no = options[:vip_no]
        @vip_phone = options[:vip_phone]
      end

      def result
        return @records if @records.present?
        set_query_params
        @records = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :wallet_id, :order_id, :reason, :note,
                            :balance, :operator_type, :operator_id, :operator_name,
                            :updated_at],
            accumulate_keys: [:amount, :cash_amount, :extra_amount]
        ) do |current_date, next_date, has_next|
          if (has_next)
            params = @branch_params.merge(st_time: current_date...next_date)
          else
            params = @branch_params.merge(st_time: current_date..next_date)
          end
          wallet_logs = shop.wallet_logs.joins(:wallet)
          .where(ddt_wallets: {type: 'Ddt::UserCardWallet'}, reason: [:for_deduction, :for_deduction_cancel, :for_vip_card_pay, :for_rollback_vip_card_pay, :for_recharge, :for_recharge_refund_complete], ddt_wallet_logs: params)
          .unscope(:order)
          .order(created_at: :desc).map{|item|
            {
              branch_id:        item.branch_id,
              wallet_id:        item.wallet_id,
              order_id:         item.order_id,
              reason:           item.reason,
              note:             item.note,
              balance:          item.balance,
              operator_name:    item.operator_name,
              operator_type:    item.operator_type,
              operator_id:      item.operator_id,
              amount:           item.amount,
              cash_amount:      item.cash_amount,
              extra_amount:     item.extra_amount,
              updated_at:       item.updated_at,

              wallet_owner_type: item.wallet.owner_type,
              wallet_owner_id:   item.wallet.owner_id
            }
          }

          if @vip_info_ids.present?
            wallet_logs = wallet_logs.select do |item|
              item[:wallet_owner_type] == 'Ddt::VipInfo' &&
                  @vip_info_ids.include?(item[:wallet_owner_id])
            end
          end

          wallet_logs
        end
      end

      def filters
        [
          filter_branch,
          filter_start_time,
          filter_end_time,
          filter_vip_no,
          filter_vip_phone
        ]
      end

      def title
        %W(日期 编号 姓名 类别 门店 充值合计 充值实收 充值赠送 消费合计 消费实收 消费赠送 余额 操作人员 订单详情 备注)
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr1 =[
          {name: '日期', th_attrs: {rowspan: '2'}},
          {name: '编号', th_attrs: {rowspan: '2'}},
          {name: '姓名', th_attrs: {rowspan: '2'}},
          {name: '类别', th_attrs: {rowspan: '2'}},
          {name: '门店', th_attrs: {rowspan: '2'}},
          {name: '操作类型', th_attrs: {rowspan: '2'}},
          {name: '充值金额', th_attrs: {colspan: '3'}},
          {name: '消费金额', th_attrs: {colspan: '3'}},
          {name: '余额', th_attrs: {rowspan: '2'}},

          {name: '操作人员', th_attrs: {rowspan: '2'}},
          {name: '订单详情', th_attrs: {rowspan: '2'}},
          {name: '备注', th_attrs: {rowspan: '2'}}
        ]
        tr2 = [
          {name: '合计'},
          {name: '实收'},
          {name: '赠送'},
          {name: '合计'},
          {name: '实收'},
          {name: '赠送'},
        ]
        thead << tr1
        thead << tr2
        thead
      end

      def body
        items = result
        content = []
        items.each do |item|
          branch_name = get_branch_name(item[:branch_id], blank_label: '平台充值', noexist_label: '未知来源')
          vip = get_vip_info(Ddt::Wallet.find(item[:wallet_id]).owner_id)
          detail = get_detail(item)
          row = []
          row << item[:updated_at].strftime('%Y-%m-%d %H:%M:%S')
          row << (vip.vip_no rescue '-')
          row << (vip.name   rescue '-')
          row << (vip.vip_level.name rescue '-')
          row << branch_name
          row << item[:reason_name]
          row << detail[:for_recharge]
          row << detail[:for_recharge_cash_amount]
          row << detail[:for_recharge_extra_amount]
          row << detail[:for_consume]
          row << detail[:for_consume_cash_amount]
          row << detail[:for_consume_extra_amount]
          row << item[:balance]
          row << item[:operator_name]
          row << item[:order_id]
          row << item[:note]
          content << row
        end
        content
      end

      cache_result


      def get_detail(item)
        h = {
          for_consume: 0,
          for_consume_cash_amount: 0,
          for_consume_extra_amount: 0,
          for_recharge: 0,
          for_recharge_cash_amount: 0,
          for_recharge_extra_amount: 0
        }

        reason = \
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

        h[reason] += amount
        h["#{reason}_cash_amount".to_sym] += cash_amount
        h["#{reason}_extra_amount".to_sym] += extra_amount
        h
      end

      def link_template
        {
          13 => order_link_template
        }
      end

      def link_hash
        items = result
        values = {}
        items.each do |item|
          if item[:order_id].present?
            values[item[:order_id]] = item[:order_id]
          end
        end
        values
      end




    end
  end
end
