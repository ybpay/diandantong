module Ddt
  module CommonApi
    module V1
      class TablesController < V1::BaseController
        before_action :set_table, only: [:show, :open, :clear, :check_out, :cancel_check_out]
        check_permission :branch, :table, {
          open: :open,
          clear: :clear,
          check_out: :check_out,
          cancel_check_out: :cancel_check_out
        }, only: [:open, :clear, :check_out, :cancel_check_out]
        def index
          @q = @current_branch.tables.includes(:table_zone).ransack(params[:q])
          @tables = @q.result(distinct: true)
        end

        def search
          index
          render :index
        end

        #
        # params[:is_local_printed] require
        #
        def check_out
          is_local_printed = (params[:is_local_printed] == true || params[:is_local_printed] == 'true') ? 1 : 0
          if @table.can_check_out?
            @table.check_out(is_local_printed)
            unless (is_local_printed)
              @table.current_order.add_change_log(:consume_bill)
              @table.current_order.save
            end
            render :show
          else
            render :json => { errors: "当前状态不允许拉取结账单"}, status: :bad_request
          end
        end

        def cancel_check_out
          if @table.can_cancel_check_out?
            @table.cancel_check_out
            render :show
          else
            render :json => { errors: "当前状态不允许重置结账单"}, status: :bad_request
          end
        end

        def show
          fresh_when(@table)
        end

        def open
          if @table.can_open?
            @table.open(params[:guest_num])
            render :show
          else
            render json: {errors: "该桌台已有订单, 不能开台"}, status: :bad_request
          end
        end

        def clear
          if @table.can_clear?
            @table.clear
            render :show
          else
            render json: { errors: "不能清台"}, status: :bad_request
          end
        end

        private

          def set_table
            @table = @current_branch.tables.includes(:table_zone).find(params[:id])
            @table.terminal_id = @terminal_id
            @table.operator = current_account
          end
      end
    end
  end
end
