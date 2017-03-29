module Ddt
  class Backend::TimeIntervalsController < Backend::BaseController
    check_permission :shop, :user, :show
    before_action :set_time_interval, only: [:edit, :update, :destroy]

    def index
      @q = @current_shop.time_intervals.ransack(params[:q])
      @time_intervals = @q.result.paginate(page: params[:page], per_page: 20)
    end

    def new
      @time_interval = @current_shop.time_intervals.new
      render 'edit', layout: false
    end

    def create
      @time_interval = @current_shop.time_intervals.build(time_interval_params)
      if @time_interval.save
      else
        render 'edit', layout: false
      end
    end

    def edit
      render 'edit', layout: false
    end

    def update
      if @time_interval.update(time_interval_params)
        render 'show', layout: false
      else
        render 'edit', layout: false
      end
    end

    def destroy
      @time_interval.destroy
    end

    private
    def set_time_interval
      @time_interval = @current_shop.time_intervals.find(params[:id])
    end

    def time_interval_params
      params.require(:time_interval).permit(:name, :start, :interval_in_hour, :_destroy)
    end

  end
end
