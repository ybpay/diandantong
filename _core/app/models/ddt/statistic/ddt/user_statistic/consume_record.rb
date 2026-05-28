module Ddt
  module UserStatistic
    class ConsumeRecord < ::Ddt::UserStatistic::Base
      attr_accessor :records, :vip_no, :vip_phone
      include Ddt::CacheModel
      cache_model 'Ddt::VipInfo', with_discarded: true


      def self.class_info
        {
          name: 'consume_record',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id, :vip_no, :vip_phone],
          label: '消费分布'
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
        # @records = shop.wallet_logs.joins(:wallet)
        # .select('ddt_wallet_logs.shop_id, branch_id, wallet_id, count(*) as count_all, -sum(ddt_wallet_logs.amount) as amount, -sum(ddt_wallet_logs.cash_amount) as cash_amount, -sum(ddt_wallet_logs.extra_amount) as extra_amount, ddt_wallet_logs.created_at')
        # .where(ddt_wallets: @vip_id_params.merge({type: 'Ddt::UserCardWallet'}), reason: [:for_exchange, :for_deduction, :for_vip_card_pay], ddt_wallet_logs: @branch_params.merge({created_at: start_time..end_time}))
        # .group(:wallet_id)
        # .group(:branch_id)
        # .unscope(:order)
        # .order(created_at: :asc)

        @records = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :created_at, :wallet_id],
            accumulate_keys: [:count_all, :amount, :cash_amount, :extra_amount]
        ) do |current_date, next_date, has_next|
          if (has_next)
            params = {st_time: current_date...next_date}
          else
            params = {st_time: current_date..next_date}
          end
          shop.wallet_logs.joins(:wallet)
          .select('ddt_wallet_logs.shop_id, branch_id, wallet_id, count(*) as count_all, -sum(ddt_wallet_logs.amount) as amount, -sum(ddt_wallet_logs.cash_amount) as cash_amount, -sum(ddt_wallet_logs.extra_amount) as extra_amount, ddt_wallet_logs.created_at')
          .where(ddt_wallets: @vip_id_params.merge({type: 'Ddt::UserCardWallet'}), reason: [:for_exchange, :for_deduction, :for_vip_card_pay], ddt_wallet_logs: @branch_params.merge(params))
          .group(:wallet_id)
          .group(:branch_id)
          .unscope(:order)
          .order(created_at: :asc).map{|line_item|
            {
              branch_id:        line_item.branch_id,
              wallet_id:        line_item.wallet_id,
              created_at:       line_item.created_at,
              count_all:        line_item.count_all,
              amount:           line_item.amount,
              cash_amount:      line_item.cash_amount,
              extra_amount:     line_item.extra_amount
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
        %W(消费门店 会员编号 姓名 性别 手机号 等级 消费金额 主账户消费金额 附属账户消费金额 最近消费时间 消费次数 平均消费)
      end

      def body
        items = self.result
        content = []
        items.each do |item|
          branch_name = get_branch_name(item.try(:branch_id))
          vip = get_vip_info(Ddt::Wallet.find(item[:wallet_id]).owner_id)
          content << [
            branch_name,
            (vip.vip_no rescue '-'),
            (vip.name   rescue '-'),
            (vip.sex_name rescue '-'),
            (vip.phone  rescue '-'),
            (vip.vip_level.name rescue '-'),
            (item[:amount]),
            (item[:cash_amount]),
            (item[:extra_amount]),
            (item[:created_at].strftime("%F")),
            (item[:count_all]),
            ((item[:amount] / item[:count_all]).round(2))
          ]
        end
        content
      end

    end
  end
end
