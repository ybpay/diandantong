module Ddt
  module Backend
    class ShiftsController < Ddt::Backend::BaseController
      check_permission :branch, :shift, {[:index, :show, :print] => :show}
      before_action :set_shift, only: [:show, :print]

      def index
        @q = @current_shop.shifts.closed.where(branch_id: managed_branch_ids).order(closed_at: :desc).ransack(params[:q])
        @shifts = @q.result.paginate(page: params[:page])
        respond_to do |format|
          format.html
          format.json {
            render json: @shifts.map(&:select_json)
          }
        end
      end

      def show
      end

      def print
      end

      private
      def set_shift
        @shift = @current_shop.shifts.find(params[:id])
      end
    end
  end
end
