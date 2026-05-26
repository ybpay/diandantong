module Ddt
  module BusinessStatistic
    class RechargeSettleSummary < ::Ddt::BusinessStatistic::Sales
      include Ddt::BusinessStatistic::Concern::GroupByTime
      attr_accessor :year, :month
      def self.class_info
        {
          name: 'recharge_settle_summary',
          paginate: false,
          permit_params: [:branch_id, :year, :month],
          default_params: this_month,
          label: '充值结算汇总',
          sortable: false
        }
      end

      def by_shift_opened_at?
        false
      end

      def extra_amounts
        return @extra_amounts if @extra_amounts.present?
        if abstract_branch?
          branch = find_one_branch
          @extra_amounts = Ddt::WalletLog.where(st_time: start_time..end_time, branch_id: nil, reason: [:for_recharge, :for_recharge_refund_complete]).group("TO_CHAR(created_at, 'MM-DD')").order(created_at: :asc).sum(:extra_amount)
        elsif one_branch?
          branch = find_one_branch
          @extra_amounts = Ddt::WalletLog.where(st_time: start_time..end_time, wallet_id: branch.card_wallet.id, reason: [:for_recharge, :for_recharge_refund_complete]).group("TO_CHAR(created_at, 'MM-DD')").order(created_at: :asc).sum(:extra_amount)
        else
          card_wallet_ids = shop.branches_include_abstract.map{|b| b.card_wallet.id}
          @extra_amounts = Ddt::WalletLog.where(st_time: start_time..end_time, wallet_id: card_wallet_ids, reason: [:for_recharge, :for_recharge_refund_complete]).group("TO_CHAR(created_at, 'MM-DD')").order(created_at: :asc).sum(:extra_amount)
        end
        @extra_amounts = keys.inject({}){|h, k| h[k] = 0; h; }.merge(@extra_amounts)
      end

      def shift_item_type
        :recharge
      end

      def initialize(options={})
        super
        initialize_month_params(options)
      end

      def group_by_column
        :paid_at_month
      end

      def shift_group_by_column
        :created_at_month
      end

      def time_format
        "#{'%02d' % month}-%02d"
      end

      def filters
        [
          filter_branch(support_abstract: true),
          filter_year,
          filter_month
        ]
      end

      def keys
        Ddt::TimeUtil.day_labels(month, year)
      end

      def csv_labels
        keys.map do |k|
          wday = Date.new(year, month, k.split('-')[1].to_i).wday
          "#{k}"
        end
      end

      def title
        %W[门店 结算方式 合计] + csv_labels
      end

      def body
        content = []
        shift_item_summarys.each do |pay_method_id, summary|
          row = [
            "",
            summary[:pay_method_name],
            summary[:series]['summary'][:amount],
          ]
          keys.each do |key|
            row << summary[:series][key][:amount]
          end
          if row[2] > 0
            content << row
          end
        end
        row = ["", "赠送"]
        row << extra_amounts.values.sum.round(2).abs
        keys.each do |key|
          row << extra_amounts[key].abs
        end
        content << row
        if content.size > 0
          content[0][0] = one_branch? ? find_one_branch.name : "所有门店"
        end
        content
      end

      def foot
        row = ["", "合计", 0]
        keys.size.times{ row << 0 }
        shift_item_summarys.each do |pay_method_id, summary|
          row[2] += summary[:series]['summary'][:amount]

          keys.each_with_index do |key, index|
            idx = 3 + index
            row[idx] += summary[:series][key][:amount]
          end
        end
        [row]
      end

      def to_combi_result
        h = {}
        shift_item_summarys.each do |k, summary|
          # k is pay_method_id
          h[k] = {
            pay_method_name:   summary[:pay_method_name],
            pay_method_code:   summary[:pay_method_code],
            amount:            summary[:series]['summary'][:amount],
            actual_amount:     summary[:series]['summary'][:actual_amount],
            not_actual_amount: summary[:series]['summary'][:no_actual_amount]
          }
        end
        h
      end

    end
  end
end
