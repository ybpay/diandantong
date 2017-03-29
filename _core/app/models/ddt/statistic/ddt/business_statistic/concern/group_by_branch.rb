module Ddt
  module BusinessStatistic
    module Concern
      module GroupByBranch
        extend ActiveSupport::Concern

        def result
          return [] if branch_id.blank?
          return @result if @result.present?
          select_columns = ['ddt_shift_items.branch_id as branch_id', 'sum(amount) as amount', 'sum(actual_amount) as actual_amount']
          group_by_columns = ['ddt_shift_items.branch_id']

          # if one_branch?
          #   @result = Ddt::ShiftItem.joins(:shift).select(select_columns.join(',')).where(item_type: shift_item_type, ddt_shifts: {state: 'closed', shop_id: shop.id, branch_id: branch_id, created_at: start_time..end_time}).group(group_by_columns.join(','))
          #   debugger
          # else
          #   @result = Ddt::ShiftItem.joins(:shift).select(select_columns.join(',')).where(item_type: shift_item_type, ddt_shifts: {state: 'closed', shop_id: shop.id, created_at: start_time..end_time}).group(group_by_columns.join(','))
          #   debugger
          # end

          params = {state: 'closed', shop_id: shop.id}
          params.merge!(branch_id: branch_id) if one_branch?

          @result = split_query_by_time(
              start_time: start_time,
              end_time: end_time,
              identity_keys: [:branch_id],
              accumulate_keys: [:amount, :actual_amount]
          ) do |current_date, next_date, has_next|
            Ddt::ShiftItem.joins(:shift)
                .select(select_columns.join(','))
                .where(item_type: shift_item_type, ddt_shifts: params.merge(created_at: has_next ? current_date...next_date : current_date..next_date))
                .group(group_by_columns.join(','))
                .map do |shift_item|
              {
                  branch_id:          shift_item.branch_id,
                  amount:             shift_item.amount,
                  actual_amount:      shift_item.actual_amount
              }
            end
          end
        end

        def shift_item_summarys_by_sql
          items = result
          items.map do |item|
            {
              branch_id: item[:branch_id],
              branch_name: get_branch_name(item[:branch_id]),
              amount: item[:amount],
              actual_amount: item[:actual_amount],
              not_actual_amount: item[:amount] - item[:actual_amount]
            }
          end
        end

        def shift_item_summarys_by_fake
          @summary_hash ||= fake_shift_items.group_by(&:branch_id)
          summary = []
          @summary_hash.each do |branch_id, items|
            summary << {
              branch_id: branch_id,
              branch_name: get_branch_name(branch_id, blank_label: '总平台', noexist_label: '未知门店'),
              amount: sum(items, :amount),
              actual_amount: sum(items, :actual_amount),
              not_actual_amount: (sum(items, :amount) - sum(items, :actual_amount))
            }
          end
          summary
        end

        def fake_shift_items
          @fake_shift_items ||= pay_item_amounts.map do |item|
            attrs = item.slice(:branch_id, :amount, :actual_amount)
            if item[:pay_method_name_sym].try(:to_sym) == :vip_card_pay
              attrs[:cash_amount] = item[:cash_amount]
              attrs[:extra_amount]= item[:extra_amount]
            end
            OpenStruct.new(attrs)
          end
        end

        def pay_item_amounts
          query_params = { shop_id_eq: shop.id, order_type_in: Ddt::OrderService::Order::Base.base_types}
          scope_params = {shop_id: shop.id}
          if one_branch?
            query_params[:branch_id_eq] = branch_id
            scope_params[:branch_id] = branch_id
          end

          @pay_item_amounts ||= split_query_by_time(
              start_time: start_time,
              end_time: end_time,
              identity_keys: [:pay_method_id, :time, :pay_method_code, :pay_method_name,
                              :paid_at, :branch_id, :pay_method_name_sym],
              accumulate_keys: [:amount, :cash_amount, :extra_amount, :actual_amount]
          ) do |current_date, next_date, has_next|
            if has_next
              pay_item_amount_params = query_params.merge(paid_at_gteq: current_date, paid_at_lt: next_date)
              time_range = current_date...next_date
            else
              pay_item_amount_params = query_params.merge(paid_at_gteq: current_date, paid_at_lteq: next_date)
              time_range = current_date..next_date
            end

            OrderService::Api::Statistic.pay_item_amount(
                query: pay_item_amount_params,
                group_by: group_by_column
            ).map do |item|
              if item[:pay_method_name_sym] == 'vip_card_pay'
                sum_amount_result = Ddt::WalletLog.joins(:wallet).where(
                    {
                        ddt_wallets: {type: 'Ddt::BranchCardWallet', owner_id: item[:branch_id] },
                        ddt_wallet_logs: scope_params.merge({
                                                                       reason: [:for_vip_card_pay, :for_rollback_vip_card_pay],
                                                                       created_at: time_range
                                                                   })
                    }).select('sum(ddt_wallet_logs.cash_amount) cash_amount_sum, sum(ddt_wallet_logs.extra_amount) extra_amount_sum').first
                if sum_amount_result.present?
                  item[:cash_amount] = sum_amount_result.cash_amount_sum || 0
                  item[:extra_amount] = sum_amount_result.extra_amount_sum || 0
                else
                  item[:cash_amount] = 0
                  item[:extra_amount] = 0
                end

                item[:actual_amount] = ((1.0 * item[:pay_method_percent_of_actual])/100) * item[:cash_amount]
              else
                item[:actual_amount] = ((1.0 * item[:pay_method_percent_of_actual])/100) * item[:amount]
              end
              item
            end
          end
        end
      end
    end
  end
end
