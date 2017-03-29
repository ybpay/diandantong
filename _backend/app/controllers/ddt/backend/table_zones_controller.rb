module Ddt
  class Backend::TableZonesController < Backend::BaseController
    check_permission :branch, :table_zone
    before_action :set_table_zone, only: [:show, :edit, :update, :destroy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }
    def index
      @q = @current_branch.table_zones.ransack(params[:q])
      @table_zones = @q.result.paginate(page: params[:page])
    end

    def show
      @q = @table_zone.tables.ransack(params[:q])
      @tables = @q.result.paginate(page: params[:page])
    end

    def new
      @table_zone = @current_branch.table_zones.build
    end

    def edit
    end

    def create
      @table_zone = @current_branch.table_zones.build(table_zone_params)

      if @table_zone.save
        redirect_to [:backend, @current_shop, @current_branch, @table_zone], notice: "#{t('activerecord.models.ddt/table_zone')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @table_zone.update(table_zone_params)
        redirect_to [:backend, @current_shop, @current_branch, @table_zone], notice: "#{t('activerecord.models.ddt/table_zone')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @table_zone.destroy
        redirect_to backend_shop_branch_table_zones_url(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/table_zone')} 删除成功."
      else
        flash[:error] = @table_zone.errors.full_messages.join('<br/>')
        redirect_to backend_shop_branch_table_zones_url(@current_shop, @current_branch)
      end
    end

    private
      def set_table_zone
        @table_zone = @current_branch.table_zones.find(params[:id])
      end

      def table_zone_params
        params.require(:table_zone).permit(:name, :min_reservation_price, :branch_id, :tables_count_for_reservation, :reservation_price, :reservation_price_percent, :weixin_ban_product_ids_string, :webpos_ban_product_ids_string, :ban_selfpay)
      end
  end
end
