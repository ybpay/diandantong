#encoding: utf-8
module Ddt
  module UserStatistic
    class RechargeRecord < ::Ddt::UserStatistic::Base
      include Ddt::CacheModel
      attr_accessor :records, :vip_no, :vip_phone
      cache_model 'Ddt::VipInfo', with_deleted: true
      hash_attrs({
         会员号: :vip_no,
         会员电话: :vip_phone
      })

      def self.class_info
        {
          name: 'recharge_record',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id, :vip_no, :vip_phone],
          label: '充值明细'
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
        @records ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :wallet_id, :order_id, :reason, :note,
                            :balance, :operator_type, :operator_id, :operator_name,
                            :created_at],
            accumulate_keys: [:amount, :cash_amount, :extra_amount]
        ) do |current_date, next_date, has_next|
          if (has_next)
            params = {st_time: current_date...next_date}
          else
            params = {st_time: current_date..next_date}
          end
          shop.wallet_logs.joins(:wallet)
          .where(ddt_wallets: @vip_id_params.merge({type: 'Ddt::UserCardWallet'}),
            reason: [:for_recharge, :for_recharge_refund_complete],
            ddt_wallet_logs: @branch_params.merge(params))
          .unscope(:order)
          .order(st_time: :asc).map{|line_item|
            {
              branch_id:        line_item.branch_id,
              wallet_id:        line_item.wallet_id,
              order_id:         line_item.order_id,
              reason:           line_item.reason,
              note:             line_item.note,
              balance:          line_item.balance,
              operator_name:    line_item.operator_name,
              operator_type:    line_item.operator_type,
              operator_id:      line_item.operator_id,
              amount:           line_item.amount,
              cash_amount:      line_item.cash_amount,
              extra_amount:     line_item.extra_amount,
              created_at:       line_item.created_at
            }
          }
        end
      end
      cache_result

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
        %W(订单 门店 时间 会员编号 姓名 性别 手机号 等级 操作者 操作类型 付款方式 充值金额 实际到帐 额外折扣 备注)
      end

      def body
        items = result
        content = []
        items.each do |item|
          branch_name = get_branch_name(item[:branch_id], blank_label: '平台充值', noexist_label: '未知来源')
          vip = get_vip_info(Ddt::Wallet.find(item[:wallet_id]).owner_id)
          content << [
            item[:order_id],
            branch_name,
            item[:created_at].strftime("%F"),
            vip.try(:vip_no),
            vip.try(:name),
            vip.try(:sex_name),
            vip.try(:phone),
            vip.try(:vip_level).try(:name),
            item[:operator_name],
            item[:reason_name],
            item[:pay_method_name],
            item[:cash_amount],
            item[:amount],
            item[:extra_amount],
            item[:note]
          ]
        end
        content
      end

      def link_template
        {
          0 => order_link_template
        }
      end

      def link_hash
        items = result
        hash = {}
        items.map{|log| hash[log[:order_id]] = log[:order_id]}
        hash
      end
    end
  end
end
