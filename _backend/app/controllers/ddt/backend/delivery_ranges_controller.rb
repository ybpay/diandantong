module Ddt
  class Backend::DeliveryRangesController < Backend::BaseController
    check_permission :branch, :delivery_setting, {:index => :show, [:edit, :update, :new, :create, :destroy] => :update}
    before_action :set_delivery_range, only: [:edit, :update, :destroy]
    layout 'ddt/layouts/backend/branch'

    def index
      @delivery_ranges = @current_branch.delivery_ranges
    end

    def edit
    end

    def destroy
      @delivery_range.destroy
    end

    def new
      @delivery_range = @current_branch.delivery_ranges.build
    end

    def create
      @delivery_range = @current_branch.delivery_ranges.build(delivery_range_params)
      @delivery_range.shop = @current_shop
      if @delivery_range.save
        index
        render :index
      else
        render :new
      end
    end

    def update
      if @delivery_range.update(delivery_range_params)
        render 'reset_tr'
      else
        render :edit
      end
    end

    private
      def set_delivery_range
        @delivery_range = @current_branch.delivery_ranges.find(params[:id])
      end

      def delivery_range_params
        params.require(:delivery_range).permit(:start_at, :end_at, :cost)
      end

  end
end