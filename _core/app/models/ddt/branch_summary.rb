module Ddt
  class BranchSummary
    attr_accessor :branch, :time_range, :start_at, :end_at, :shop, :time_interval_id

    def initialize(branch, start_at:, end_at:, time_interval_id: nil)
      @branch = branch
      @start_at = start_at
      @end_at = end_at
      @time_range = start_at..end_at
      @shop = branch.shop
      @time_interval_id = time_interval_id
      if @time_interval_id.present?
        @time_interval = @shop.time_intervals.find(@time_interval_id)
      end
    end

    def pay_item_amounts
      @pay_item_amounts ||= OrderService::Api::Statistic.pay_item_amount(
          where: Ddt::StatisticBase.build_time_interval_clause(@time_interval),
          query: base_query_params
      ).map do |item|
        if item[:pay_method_name_sym] == 'vip_card_pay'
          item[:cash_amount] = self.branch.card_wallet.wallet_logs.where(reason: [:for_vip_card_pay, :for_rollback_vip_card_pay], created_at: time_range).sum(:cash_amount)
          item[:extra_amount] = self.branch.card_wallet.wallet_logs.where(reason: [:for_vip_card_pay, :for_rollback_vip_card_pay], created_at: time_range).sum(:extra_amount)
          item[:actual_amount] = ((1.0 * item[:pay_method_percent_of_actual])/100) * item[:cash_amount]
        else
          item[:actual_amount] = ((1.0 * item[:pay_method_percent_of_actual])/100) * item[:amount]
        end
        item
      end
    end

    def recharge_pay_item_amounts
      @recharge_pay_item_amounts ||= OrderService::Api::Statistic.pay_item_amount(
          where: Ddt::StatisticBase.build_time_interval_clause(@time_interval),
          query: base_recharge_query_params
      ).map do |item|
        item[:actual_amount] = ((1.0 * item[:pay_method_percent_of_actual])/100) * item[:amount]
        item
      end
    end

    def total_amount
      @total_amount ||= pay_item_amounts.map{|item| item[:amount]}.sum.to_f.round(2)
    end

    def actual_amount
      @actual_amount ||= pay_item_amounts.map{|item| item[:actual_amount].present? ? item[:actual_amount] : 0 }.sum.to_f.round(2)
    end

    def unpaid_amount
      @unpaid_amount ||= OrderService::Api::Statistic.order_amount(
        query: {
          state_not_eq: 'canceled',
          type_eq: 'Ddt::EatInHallOrder',
          branch_id_eq: branch.id,
          placed_at_gteq: start_at,
          placed_at_lteq: end_at,
          pay_item_state_in: ['none', 'unpaid']
          })
    end

    def discount_amount
      @discount_amount ||= Ddt::OrderService::Api::Statistic.adjustment_amount(query: {
        branch_id_eq: branch.id,
        created_at_gteq: start_at,
        created_at_lteq: end_at,
        reason_in: Ddt::OrderService::Adjustment.discount_reasons
      })
    end

    def moling_amount
      @moling ||= Ddt::OrderService::Api::Statistic.order_moling_amount(query: {
        branch_id_eq: branch.id,
        paid_at_gteq: start_at,
        paid_at_lteq: end_at,
      })
    end

    def customter_count
      @customter_count ||= OrderService::Api::Statistic.guest_num_count(query: base_query_params)
    end

    def recharge_amount
      return @recharge_amount if @recharge_amount.present?
      # 退款审核时间可能置后, 故先找出充值订单，再通过订单找退款记录
      items = branch.card_wallet.wallet_logs.where(created_at: time_range, reason: [:for_recharge]).select(:order_id, :cash_amount)
      related_order_ids = []
      @recharge_amount = 0.0
      items.each do |item|
        related_order_ids << item.order_id
        @recharge_amount -= item.cash_amount
      end
      @recharge_amount -= (branch.card_wallet.wallet_logs.where(reason: :for_recharge_refund_complete, order_id: related_order_ids).sum(:cash_amount).to_f || 0)
      @recharge_amount = 0 if @recharge_amount == 0.0
      @recharge_amount
    end

    def recharge_extra_amount
      return @recharge_extra_amount if @recharge_extra_amount.present?
      items = branch.card_wallet.wallet_logs.where(created_at: time_range, reason: [:for_recharge]).select(:order_id, :extra_amount)
      related_order_ids = []
      @recharge_extra_amount = 0.0
      items.each do |item|
        related_order_ids << item.order_id
        @recharge_extra_amount -= item.extra_amount
      end
      @recharge_extra_amount -= (branch.card_wallet.wallet_logs.where(reason: :for_recharge_refund_complete, order_id: related_order_ids).sum(:extra_amount).to_f || 0)
      @recharge_extra_amount = 0 if @recharge_extra_amount == 0.0
      @recharge_extra_amount
    end

    def vip_card_pay_amount
      @vip_card_pay_amount ||= OrderService::Api::Statistic.pay_item_amount(query: base_query_params.merge(pay_method_name_sym_eq: "vip_card_pay"))[0].try(:[], :amount) || 0
    end

    def recharge_order_count
      @recharge_order_count ||= OrderService::Api::Statistic.order_quantity(query: base_recharge_query_params)
    end

    def exchange_amount
      @exchange_amount ||= branch.card_wallet.wallet_logs.where(created_at: time_range, reason: :for_exchange).sum(:cash_amount).abs || 0
    end

    def track_from_quantities
      @track_from_quantities ||= OrderService::Api::Statistic.order_quantity(query: base_query_params, group_by: :track_from)
    end

    def eat_in_hall_order_count
      @eat_in_hall_order_count ||= OrderService::Api::Statistic.order_quantity(query: eat_in_hall_order_query_params)
    end

    def eat_in_hall_order_amount
      @eat_in_hall_order_amount ||= OrderService::Api::Statistic.order_sale_amount(query: eat_in_hall_order_query_params)
    end

    def subtract_item_count
      @subtract_item_count ||= subtract_item_list.map{|item| item[:quantity]}.sum
    end

    def subtract_item_amount
      @subtract_item_amount ||= subtract_item_list.map{|item| item[:quantity] * item[:price]}.sum
    end

    private

    def base_query_params
      {
        branch_id_eq: branch.id,
        paid_at_gteq: time_range.begin,
        paid_at_lteq: time_range.end,
        order_type_in: Ddt::OrderService::Order::Base.base_types,
        type_in: Ddt::OrderService::Order::Base.base_types,
      }
    end

    def base_recharge_query_params
      {
        branch_id_eq: branch.id,
        paid_at_gteq: time_range.begin,
        paid_at_lteq: time_range.end,
        type_eq: "Ddt::RechargeOrder",
        state_not_cont: "refund",
        order_type_eq: "Ddt::RechargeOrder"
      }
    end

    def eat_in_hall_order_query_params
      base_query_params.merge(type_eq: "Ddt::EatInHallOrder")
    end

    def subtract_item_list
      query_params = {branch_id_eq: branch.id, order_paid_at_gteq: @start_at, order_paid_at_lteq: @end_at}
      @subtract_item_list ||= OrderService::Api::Statistic.subtract_item_list(query: query_params)
    end

  end
end
