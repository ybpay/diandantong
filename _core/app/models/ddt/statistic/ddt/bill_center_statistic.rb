#encoding: utf-8
# webpos 的统计

module Ddt
  class BillCenterStatistic

    def initialize(params)
      @branch = Ddt::Branch.find(params[:branch_id])
      @start_time = Time.parse(params[:start_time])
      @end_time = Time.parse(params[:end_time])
      @current_account = Ddt::Account.find(params[:current_account_id])
      @search_by = params[:search_by]
      @start_at = params[:start_at]
      @end_at = params[:end_at]
      @date = params[:date]

      @category_ids = params[:category_ids]
      @variant_ids = params[:variant_ids]
      @time_interval_id = params[:time_interval_id]
      @pay_item_state = params[:pay_item_state]
    end

    concerning :Async do
      included do
        CACHE_TTL = 1.hour

        def self.async_query_bill(action_name, params)
          refresh = params.delete(:refresh)
          cache_key = self.cache_key(action_name, params)

          if refresh == 'true'
            Rails.cache.delete(cache_key)
            value = nil
          else
            value = Rails.cache.read(cache_key)
          end

          if value.present?
            if value == '::commit::'
              result = {
                  :'$state' => 'loading',
                  :'$status' => 200
              }
            else
              result = JSON.parse(value)
              result.merge!(:'$state' => 'success', :'$status' => 200, from_cache: true)
            end
          else
            Rails.cache.write(cache_key, '::commit::', expires_in: CACHE_TTL)
            self.delay_for(5.seconds, :queue => 'statistics').query_bill(action_name, params)
            result = {
                :'$state' => 'loading',
                :'$status' => 200
            }
          end
          result
        end

        def self.query_bill(action_name, params)
          cache_key = self.cache_key(action_name, params)
          result = Ddt::BillCenterStatistic.new(params).send(action_name)

          Rails.cache.write(cache_key, result.to_json, expires_in: CACHE_TTL)
          result
        end

        def self.cache_key(action_name, params)
          'webpos_bill_' + Digest::SHA1.hexdigest([action_name, params].to_s)
        end

        def self.delete_cache(filename)
          Rails.cache.delete(filename)
        end
      end
    end


    concerning :Statistics do

      def discount_list
        @list ||= Ddt::Bill::Branch::DiscountList.new(@branch,start_time: @start_time ,end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map { |item|
              {
                  order_number: item.order_number,
                  table_name: item.table_name,
                  created_at: item.created_at,
                  label: item.label,
                  amount: item.amount,
                  operator_name: item.operator_name,
                  authorizer_name: item.authorizer_name
              }
            },
            total_discount_amount: @list.total_discount_amount
        }
      end

      def waiter_list
        @list ||= Ddt::Bill::Branch::WaiterList.new(@branch,start_time: @start_time ,end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map { |item|
              {
                  waiter_name: item.waiter_name,
                  order_count: item.order_quantity,
                  order_amount: item.order_sale_amount,
                  order_average: item.average_sale_amount
              }
            },
            total_orders_amount: @list.total_orders_amount
        }
      end

      def gift_item_list
        @list ||= Ddt::Bill::Branch::GiftItemList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map { |item|
              {
                  order_number: item.order_number,
                  table_name: item.table_name_with_zone,
                  name: item.itemable_name,
                  quantity: item.quantity,
                  price: item.original_price,
                  reason: item.gift_reason,
                  created_at: item.created_at
              }
            },
            total_quantity: @list.items.map(&:quantity).sum,
            total_amount: @list.items.map{|i| i.original_price * i.quantity}.sum
        }
      end

      def subtract_item_list
        @list = Ddt::Bill::Branch::SubtractItemList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            total_amount: @list.total_amount,
            total_quantity: @list.total_quantity,
            items: @list.items.map do |item|
              {
                  order_number: item.order_number,
                  table_name_with_zone: item.table_name_with_zone,
                  created_at: item.created_at,
                  itemable_name: item.itemable_name,
                  quantity: item.quantity,
                  price: item.price,
                  subtract_reason: item.subtract_reason,
                  amount: item.amount,
                  operator_name: item.operator_name
              }
            end
        }
      end

      def sale_list
        @list ||= Ddt::Bill::Branch::SaleList.new(
            @branch, start_time: @start_time, end_time: @end_time,
            category_ids: @category_ids,
            variant_ids: @variant_ids,
            operator: @current_account,
            time_interval_id: @time_interval_id,
            pay_item_state: @pay_item_state
        )

        group_items = {}
        @list.group_items.map do |group_name, items|
          group_items[group_name] = items.map do |item|
            {
                name: item.name,
                quantity: item.quantity,
                adjustment_total: item.adjustment_total,
                not_actual_amount: item.not_actual_amount,
                amount: item.amount,
                percent: item.percent
            }
          end
        end
        @result ||= {
            bill: @list.content,
            total_amount: @list.total_amount,
            total_quantity: @list.total_quantity,
            total_adjustment: @list.total_adjustment,
            total_not_actual_amount: @list.total_not_actual_amount,
            moling_amount: @list.moling_amount,
            group_items: group_items
        }
      end

      def payment_list
        @list ||= Ddt::Bill::Branch::PaymentList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map { |item|
              {
                  order_number: (@list.order_numbers[item.order_id] rescue nil),
                  amount: item.amount,
                  payment_method_name: item.payment_method.name,
                  state_name: item.workflow_state_name,
                  state: item.state,
                  out_trade_no: item.out_trade_no,
                  created_at: item.created_at.strftime('%F %H:%M'),
                  deleted_at: item.deleted_at.present? ? item.deleted_at.strftime('%F %H:%M') : nil
              }
            }
        }
      end

      def shift_list
        @list ||= Ddt::Bill::Branch::ShiftList.new(
            @branch, search_by: @search_by,
            start_time: @start_time, end_time: @end_time, start_at: @start_at, end_at: @end_at, date: @date,
            # time_interval_id: params[:time_interdval_id],
            operator: @current_account
        )
        @result ||= {
            bill: @list.content,
            items: @list.items.map { |item|
              {
                  name: item.name,
                  shift_items: item.items.map {|item|
                    {
                        pay_method_name: item.pay_method_name,
                        pay_method_code: item.pay_method_code,
                        amount: item.amount,
                        cash_amount: item.cash_amount,
                        extra_amount: item.extra_amount
                    }
                  },
                  total_amount: item.total_amount,
                  total_actual_amount: item.total_actual_amount,
                  label_items: item.label_items
              }
            }
        }
      end

      def combo_package_list
        @list ||= Ddt::Bill::Branch::ComboPackageList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            total_sale_quantity: @list.total_sale_quantity,
            total_sale_amount: @list.total_sale_amount,
            items: @list.group_items.map do |item|
              {
                  name: item[:name],
                  sale_quantity: item[:sale_quantity],
                  sale_amount: item[:sale_amount],
                  variants: Hash[*item[:variants].map{|name, quantity|[name, quantity]}.flatten]
              }
            end
        }
      end

      def order_cancel_list
        @list ||= Ddt::Bill::Branch::OrderCancelList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map do |item|
              {
                  order_number: item.order_number,
                  order_type: item.order_type_name,
                  table_name: item.order_table_name_with_zone,
                  order_amount: item.order_total,
                  created_at: item.created_at.strftime('%F %T'),
                  operator_name: item.operator_name
              }
            end
        }
      end

      def anti_settlement_list
        @list ||= Ddt::Bill::Branch::AntiSettlementList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map do |item|
              {
                  order_number: item.order_number,
                  table_name: item.order_table_name_with_zone,
                  description: item.description,
                  created_at: item.created_at.strftime('%F %T'),
                  operator_name: item.operator_name
              }
            end
        }
      end

      def queue_list
        @list ||= Ddt::Bill::Branch::QueueList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            items: @list.items.map do |item|
              {
                  name: item[:name],
                  total: item[:total],
                  queueing: item[:queueing],
                  accepted: item[:accepted],
                  accepted_rate: item[:accepted_rate],
                  rejected: item[:rejected],
                  rejected_rate: item[:rejected_rate]
              }
            end
        }
      end

      def by_weight_product_list
        @list ||= Ddt::Bill::Branch::ByWeightProductList.new(@branch, start_time: @start_time, end_time: @end_time, operator: @current_account)
        @result ||= {
            bill: @list.content,
            total_amount: @list.total_amount,
            total_quantity: @list.total_quantity,
            items: @list.group_items.map { |item|
              {
                  name: item[:name],
                  unit_name: item[:unit_name],
                  total_quantity: item[:total_quantity],
                  total_amount: item[:total_amount],
                  total_weight: item[:total_weight],
                  variants: item[:variants].map { |variant|
                    {
                        name: variant[:name],
                        weight: variant[:weight],
                        quantity: variant[:quantity],
                        amount: variant[:amount],
                        percent: variant[:percent]
                    }
                  }
              }
            }
        }
      end

    end

  end
end
