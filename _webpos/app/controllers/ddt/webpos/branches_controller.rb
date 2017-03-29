module Ddt
  module Webpos
    class BranchesController < Webpos::BaseController
      respond_to :json
      before_action :set_branch, only: [:show, :open_shift, :get_shift, :close_shift, :print_shift, :waiter_names, :sdu_upload_orders, :sdu_query_orders, :cache_versions]
      check_permission :branch, :branch, {
        open_shift: :open_shift,
        [:close_shift, :sdu_upload_orders, :sdu_query_orders] =>  :close_shift,
      }, only: [:open_shift, :close_shift, :sdu_upload_orders, :sdu_query_orders]

      def index
        @branches = current_account.managed_branches.valid_now
        if stale?(@branches)
          render json: @branches.map{|branch| branch.as_json(only: [:id, :name])}
        end
      end

      def show
       fresh_when(@branch)
      end

      def cache_versions
      end

      def open_shift
        if @branch.open_shift(current_account, params[:pre_cash_amount])
          @branch.reload
          render :show
        else
          render json: { errors: @branch.errors.full_messages }, status: :bad_request
        end
      end

      def close_shift
        if @branch.close_shift
          @branch.reload
          render :show
        else
          render json: { errors: @branch.errors.full_messages }, status: :bad_request
        end
      end

      def get_shift
        @shift = @branch.current_shift
        if @shift.present?
          @shift.update_amount
        else
          render json: { errors: "当前店铺没有开班" }, status: :bad_request
        end
      end

      def print_shift
        @shift = @branch.shifts.find(params[:shift_id])
        bill_type = params.fetch(:bill_type, :base).try(:to_sym)
        case bill_type
        when :base
          content = BillTemplate::Shift::Bill.new(@shift).render
        when :recharge
          content = BillTemplate::Shift::RechargeBill.new(@shift).render
        end
        webpos_printers = @branch.printers.use_in_webpos.active
        webpos_printers.each do |printer|
          printer.print(content)
        end
        render json: :ok
      end

      def sdu_upload_orders
        @shift = @branch.current_shift
        SaleDataUploaderSetting.delay.upload_orders(@branch.id, @shift.created_at, Time.now)
        render json: :ok
      end

      def sdu_query_orders
        @shift = @branch.current_shift
        @result = SaleDataUploaderSetting.query_orders(@branch.id, @shift.created_at, Time.now)
        render json: {
          uploaded: @result[:uploaded].count,
          pending:  @result[:pending].count,
          canceled: @result[:canceled].count,
          not_find: @result[:not_find].count,
        }
      end

      def waiter_names
        waiters = @branch.managers.waiters
        render json: waiters.map(&:select_json)
      end

      private
      def set_branch
        @branch = current_shop.branches_include_abstract.find(params[:id])
      end

    end
  end
end
