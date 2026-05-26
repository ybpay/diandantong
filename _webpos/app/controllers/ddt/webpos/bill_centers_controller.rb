module Ddt
  module Webpos
    class BillCentersController < Webpos::BaseController
      respond_to :json
      before_action :set_branch
      before_action :set_start_time_and_end_time
      before_action :set_start_at_and_end_at, only: [:shift_list]
      check_permission :branch, :bill_center, {
          discount_list: :discount_list,
          waiter_list: :waiter_list,
          gift_item_list: :gift_item_list,
          subtract_item_list: :subtract_item_list,
          sale_list: :sale_list,
          payment_list: :payment_list,
          shift_list: :shift_list,
          combo_package_list: :combo_package_list,
          order_cancel_list: :order_cancel_list,
          anti_settlement_list: :anti_settlement_list,
          queue_list: :queue_list,
          by_weight_product_list: :by_weight_product_list,
      }

      around_action :query_by_cache, only: [
          :discount_list,
          :waiter_list,
          :gift_item_list,
          :subtract_item_list,
          :sale_list,
          :payment_list,
          :shift_list,
          :combo_package_list,
          :order_cancel_list,
          :anti_settlement_list,
          :queue_list,
          :by_weight_product_list
      ]

      # before_action :redirect_to_not_permit

      def query_by_cache
        async_params = {
            branch_id: @branch.id,
            start_time: @start_time.strftime('%F %T'),
            end_time: @end_time.strftime('%F %T'),
            current_account_id: current_account.id
        }
        async_params[:search_by] = params[:search_by] if params[:search_by].present?
        async_params[:start_at] = @start_at if @start_at.present?
        async_params[:end_at] = @end_at if @end_at.present?
        async_params[:date] = @date if @date.present?

        async_params[:category_ids] = params[:category_ids] if params[:category_ids].present?
        async_params[:variant_ids] = params[:variant_ids] if params[:variant_ids].present?
        async_params[:time_interval_id] = params[:time_interval_id] if params[:time_interval_id].present?
        async_params[:pay_item_state] = params[:pay_item_state] if params[:pay_item_state].present?

        async_params[:refresh] = params[:refresh] if params[:refresh].present?

        if @end_time.present? and @start_time.present? and @end_time - @start_time <= 3.days
          result = Ddt::BillCenterStatistic.query_bill(action_name, async_params)
          result.merge!(:'$state' => 'success', :'$status' => 200)
          result
        else
          result = Ddt::BillCenterStatistic.async_query_bill(action_name, async_params)
        end
        render json: result, status: result[:'$status']
      end

      private
      def set_branch
        @branch = current_account.managed_branches.find(params[:branch_id])
      end

      # def redirect_to_not_permit
      #   render json: {errors: '因系统升级，暂时禁止查询报表，晚上9:00后恢复'}, status: :bad_request
      #   false
      # end

      def set_start_time_and_end_time
        shift_marks = ['$current_shift.open_time', '$current_shift.close_time', '$last_shift.open_time', '$last_shift.close_time']
        if params[:start_time] == shift_marks[0]
          @start_time = @current_branch.current_shift.try(:created_at)
        end
        if params['start_time'] == shift_marks[2]
          @start_time = @current_branch.last_shift.try(:created_at)
        end
        if params['end_time'] == shift_marks[1]
          @end_time = @current_branch.current_shift.try(:closed_at) || Time.now
        end
        if params['end_time'] == shift_marks[3]
          @end_time = @current_branch.last_shift.try(:closed_at) || Time.now
        end

        if @start_time.blank?
          if params[:start_time].blank? || shift_marks.include?(params[:start_time])
            @start_time = Date.today.beginning_of_day
          else
            @start_time = (Time.parse(params[:start_time]) rescue nil)
          end
        end

        if @end_time.blank?
          if params[:end_time].blank? || shift_marks.include?(params[:start_time])
            @end_time = Date.today.end_of_day
          else
            @end_time = (Time.parse(params[:end_time]) rescue nil)
          end
        end

        if (@start_time == nil) or (@end_time == nil)
          render json: {errors: '输入的开始时间或结束时间格式不正确'}, status: :bad_request
        end
      end

      def set_start_at_and_end_at
        @search_by = params[:search_by] || 'by_shift'
        @start_at = nil
        @end_at = nil
        @date = nil
        if 'by_time' == @search_by
          @start_at = params[:start_at] || '09:00'
          @end_at = params[:end_at] || '16:00'
          @date = params[:date] || Date.today.strftime("%Y-%m-%d")
        end
      end
    end

  end
end