module Ddt
  module Webpos
    class TablesController < Webpos::BaseController
      before_action :set_table, except: [:index, :get_changed_tables, :get_reservation_tables]
      check_permission :branch, :table, {
        open: :open,
        clear: :clear,
        update_guest_num: :update_guest_num,
        [:check_out, :cancel_check_out] => :check_out,
        force_clear: :force_clear,
      }, except: [:index, :show, :get_changed_tables, :get_reservation_tables, :get_consume_bill]

      def index
        @tables = @current_branch.tables.ransack(params[:q]).result
      end

      def show
        @table.current_order = Ddt::OrderService::Orders.includes(:line_items, :adjustments, :form_contents).find(@table.current_order_id) if @table.current_order_id.present?
        fresh_when([@table, @table.current_order])
      end

      def open
        if @table.can_open?
          @table.open(params[:table][:guest_num])
          render :show
        else
          render json: {errors: "该桌台已有订单, 不能开台"}, status: :bad_request
        end
      end

      def get_changed_tables
        @tables = @current_branch.tables.where("updated_at > ?", params[:last_refresh_at]).include_current_order
      end

      def get_reservation_tables
        @date = Date.parse(params[:reservation_date])
        @time_point = @current_branch.reservation_time_points.find(params[:time_point_id])
        @reservation_infos = @time_point.reservation_infos.where(reservation_date: @date..@date.next)
        @tables = @time_point.table_zone.tables.includes(:table_zone)
        @reserved_tables = @time_point.reserved_tables(@date)
      end

      def clear
        if @table.can_clear?
          @table.clear
          render :show
        else
          render :json => { errors: "不能清台"}, status: :bad_request
        end
      end

      def update_guest_num
        @table.update_guest_num(params[:guest_num])
        render :show
      end

      def check_out
        if @table.can_check_out?
          @table.check_out(params[:is_local_printed].present?||false ? 1 : 0)
        end
        render json: {}
      end

      def cancel_check_out
        if @table.can_cancel_check_out?
          @table.cancel_check_out
          render json: {}
        else
          render :json => { errors: "当前状态不允许重置结账单"}, status: :bad_request
        end
      end

      def force_clear
        @table.force_clear
        render json: {}
      end

      def get_consume_bill
        order = @table.current_order
        if order.present?
          bill = order.order_detail_in_bill(
            print_spec: params[:bill_type],
            is_consume_bill: true,
            bill_operator: current_account
          )
          order.add_change_log(:consume_bill)
          order.save
          render json: { bill: bill }
        else
          render json: { errors: '桌台还没下单'}
        end
      end

      private
      def set_table
        @table = @current_branch.tables.includes(:table_zone).where(id: params[:id]).first
        @table.operator = current_account
      end
    end
  end
end
