module Ddt
  module BusinessStatistic
    module Concern
      module GroupByTime
        extend ActiveSupport::Concern

        def all_pay_methods
          shop.pay_methods.with_discarded.inject({}) do |h, m|
            h[m.id] ={
              pay_method_id: m.id,
              pay_method_code: m.code,
              pay_method_name: m.name,
              series: {
                'summary' => {
                  amount: 0,
                  actual_amount: 0,
                  no_actual_amount: 0
                }
              }
            }
            h
          end
        end

        def fill_empty(summarys)
          if @fill_empty
            summarys.each do |k, summary|
              keys.each do |key|
                if summary[:series][key].nil?
                  summary[:series][key] = {
                    amount: 0,
                    actual_amount: 0,
                    no_actual_amount: 0
                  }
                end
              end
            end
          end
          summarys
        end

        def year_fill_empty(summarys)
          if @fill_empty
            summarys.each do |k, value|
              value.each do |v, summary|
                keys.each do |key|
                  if summary[:series][key].nil?
                    summary[:series][key] = {
                      amount: 0,
                      actual_amount: 0,
                      no_actual_amount: 0
                    }
                  end
                end
              end
            end
          end
          summarys
        end

        def result
          return [] if branch_id.blank?
          return @result if @result.present?
          select_columns = [ 'pay_method_id', 'pay_method_code', 'pay_method_name','sum(amount) as amount', 'sum(actual_amount) as actual_amount']
          select_columns << append_select_column
          select_columns.compact!
          group_by_columns = [ 'pay_method_id']
          group_by_columns << append_group_column
          group_by_columns.compact!

          if shift_group_by_column.present?
            select_columns.insert(1, select_by_time_type_to_sql_simple(shift_group_by_column, table_name: :ddt_shifts))
            group_by_columns.insert(1, group_by_time_type_to_sql_simple(shift_group_by_column, table_name: :ddt_shifts))
          end
          if one_branch?
            @result = Ddt::ShiftItem.joins(:shift).select(select_columns.join(',')).where(item_type: shift_item_type, ddt_shifts: {state: 'closed', shop_id: shop.id, branch_id: branch_id, created_at: start_time..end_time}).group(group_by_columns.join(','))
          else
            @result = Ddt::ShiftItem.joins(:shift).select(select_columns.join(',')).where(item_type: shift_item_type, ddt_shifts: {state: 'closed', shop_id: shop.id, created_at: start_time..end_time}).group(group_by_columns.join(','))
          end
        end

        def shift_item_summarys_by_sql
          #pay_methods = all_pay_methods
          pay_methods = {}
          items = result
          summary_hash = items.group_by(&:pay_method_id)
          summary_hash.each do |id, sitems|
            amount = sum(sitems, :amount)
            actual_amount = sum(sitems, :actual_amount)
            no_actual_amount = amount - actual_amount
            first = sitems[0]
            pay_method = {
              pay_method_id: id,
              pay_method_code: first.pay_method_code,
              pay_method_name: first.pay_method_name,
              series: {
                'summary' => {
                  amount: amount,
                  actual_amount: actual_amount,
                  no_actual_amount: no_actual_amount
                }
              }
            }
            if shift_group_by_column.present?
              details = {}
              sitems.each do |item|
                k = time_format % item.time.to_i
                details[k] = {
                  amount: item.amount,
                  actual_amount: item.actual_amount,
                  no_actual_amount: item.amount - item.actual_amount
                }
              end
              pay_method[:series].merge! details
            end
            pay_methods[first.pay_method_id] = pay_method
          end
          fill_empty(pay_methods)
        end

        def  year_shift_item_summarys_by_sql
          pay_methods = {}
          items = result
          b_hash = items.group_by(&:branch_id)
          b_hash.each do |b_id, value|
            p_hash = value.group_by(&:pay_method_id)
            pay_methods[b_id] = {}
            p_hash.each do |p_id, sitems|
              amount = sum(sitems, :amount)
              actual_amount = sum(sitems, :actual_amount)
              no_actual_amount = amount - actual_amount
              first = sitems[0]
              pay_method = {
                pay_method_id: p_id,
                pay_method_code: first.pay_method_code,
                pay_method_name: first.pay_method_name,
                series: {
                  'summary' => {
                    amount: amount,
                    actual_amount: actual_amount,
                    no_actual_amount: no_actual_amount
                  }
                }
              }
              if shift_group_by_column.present?
                details = {}
                sitems.each do |item|
                  k = time_format % item.time.to_i
                  details[k] = {
                    amount: item.amount,
                    actual_amount: item.actual_amount,
                    no_actual_amount: item.amount - item.actual_amount
                  }
                end
                pay_method[:series].merge! details
              end
              pay_methods[b_id][first.pay_method_id] = pay_method
            end
          end
          year_fill_empty(pay_methods)
        end

        def shift_item_summarys_by_fake
          @summary_hash ||= fake_shift_items.group_by(&:pay_method_id)
          #pay_methods = all_pay_methods
          pay_methods = {}

          @summary_hash.each do |id, sitems|
            amount = sum(sitems, :amount)
            actual_amount = sum(sitems, :actual_amount)
            no_actual_amount = amount - actual_amount
            first = sitems[0]
            pay_method = {
              pay_method_id: id,
              pay_method_code: first.pay_method_code,
              pay_method_name: first.pay_method_name,
              series: {
                'summary' => {
                  amount: amount,
                  actual_amount: actual_amount,
                  no_actual_amount: no_actual_amount
                }
              }
            }

            if filter_blk.present?
              details = {}
              sitems.group_by(&filter_blk).each do |detail, sitems|
                details[detail] = {
                  amount: sum(sitems, :amount),
                  actual_amount: sum(sitems, :actual_amount),
                  no_actual_amount: sum(sitems, :amount) - sum(sitems, :actual_amount)
                }
              end
              pay_method[:series].merge! details
            end

            pay_methods[first.pay_method_id] = pay_method
          end
          fill_empty(pay_methods)
        end

        def fake_shift_items
          @fake_shift_items ||= pay_item_amounts.map do |item|
            amount = item[:amount]
            attrs = item.slice(:paid_at, :pay_method_id, :amount, :actual_amount, :pay_method_name, :pay_method_code)
            if item[:pay_method_name_sym].try(:to_sym) == :vip_card_pay
              attrs[:cash_amount] = item[:cash_amount]
              attrs[:extra_amount]= item[:extra_amount]
            end
            OpenStruct.new(attrs)
          end
        end

        def pay_item_amounts
          query_params = { shop_id_eq: shop.id, paid_at_gteq: start_time, paid_at_lteq: end_time, order_type_in: order_types}
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
            OrderService::Api::Statistic.pay_item_amount({
              query: pay_item_amount_params,
              group_by: group_by_column
            }).map do |item|
              if item[:pay_method_name_sym] == 'vip_card_pay'
                sum_amount_result = Ddt::WalletLog.joins(:wallet).where(
                    {
                        ddt_wallets: {type: 'Ddt::BranchCardWallet' },
                        ddt_wallet_logs: scope_params.merge({
                                                                       reason: [:for_vip_card_pay, :for_rollback_vip_card_pay],
                                                                       created_at: time_range
                                                                   })
                    })
                    .where("#{wallet_log_time_format} = '#{paid_at_time_format item[:paid_at]}'")
                    .select('sum(ddt_wallet_logs.cash_amount) cash_amount_sum, sum(ddt_wallet_logs.extra_amount) extra_amount_sum').first
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

        def order_types
          if shift_item_type == :recharge
            Ddt::OrderService::Order::Base.recharge_types
          else
            Ddt::OrderService::Order::Base.base_types
          end
        end



      end
    end
  end
end
