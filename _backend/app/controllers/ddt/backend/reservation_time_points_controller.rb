module Ddt
  class Backend::ReservationTimePointsController < Backend::BaseController
    check_permission :branch, :reservation_setting, { [:show, :index] => :show, [:new, :create, :edit, :update, :destroy, :get_batch_create, :post_batch_create] => :update}
    before_action :set_reservation_time_point, only: [:show, :edit, :update, :destroy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }
    def index
      @q = @current_branch.reservation_time_points.ransack(params[:q])
      @reservation_time_points = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @reservation_time_point = @current_branch.reservation_time_points.build
    end

    def edit
    end

    def create
      @reservation_time_point = @current_branch.reservation_time_points.build(reservation_time_point_params)

      if @reservation_time_point.save
        redirect_to [:backend, @current_shop, @current_branch, @reservation_time_point], notice: "#{t('activerecord.models.ddt/reservation_time_point')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @reservation_time_point.update(reservation_time_point_params)
        redirect_to [:backend, @current_shop, @current_branch, @reservation_time_point], notice: "#{t('activerecord.models.ddt/reservation_time_point')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @reservation_time_point.destroy
        redirect_to backend_shop_branch_reservation_time_points_url(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/reservation_time_point')} 删除成功."
      else
        flash[:error] = @reservation_time_point.errors.full_messages.join('<br/>')
        redirect_to backend_shop_branch_reservation_time_points_url(@current_shop, @current_branch)
      end
    end

    def get_batch_create
      @batch_create_reservation_time_point_form = Ddt::BatchCreateReservationTimePointForm.new
    end

    def post_batch_create
      @batch_create_reservation_time_point_form = Ddt::BatchCreateReservationTimePointForm.new(batch_create_params.merge({branch: @current_branch}))
      if @batch_create_reservation_time_point_form.valid?
        @batch_create_reservation_time_point_form.perform
        redirect_to [:backend, @current_shop, @current_branch, :reservation_time_points], notice: "批量创建成功."
      else
        render :get_batch_create
      end
    end

    private
      def set_reservation_time_point
        @reservation_time_point = @current_branch.reservation_time_points.find(params[:id])
      end

      def reservation_time_point_params
        params.require(:reservation_time_point).permit(:time_point, :table_zone_id, :branch_id)
      end

      def batch_create_params
        params.require(:batch_create_reservation_time_point_form).permit(:start_time_point, :interval, :count, :table_zone_id)
      end
  end
end
