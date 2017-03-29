module Ddt
  class Backend::ZonesController < Backend::BaseController
    check_permission :shop, :zone
    before_action :set_zone, only: [:show, :edit, :update, :destroy]

    def index
      @q = @current_shop.zones.ransack(params[:q])
      @zones = @q.result.paginate(page: params[:page])

      respond_to do |format|
        format.html
        format.json {
          render :json => @zones.flatten.map(&:select_json)
        }
      end
    end

    def show
    end

    def new
      @zone = @current_shop.zones.build
    end

    def edit
    end

    def create
      @zone = @current_shop.zones.build(zone_params)

      if @zone.save
        redirect_to [:backend, @current_shop, @zone], notice: "#{t('activerecord.models.ddt/zone')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @zone.update(zone_params)
        redirect_to [:backend, @current_shop, @zone], notice: "#{t('activerecord.models.ddt/zone')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @zone.destroy
        redirect_to backend_shop_zones_url(@current_shop), notice: "#{t('activerecord.models.ddt/zone')} 删除成功."
      else
        flash[:error] = @zone.errors.full_messages.join('<br/>')
        redirect_to backend_shop_zones_url(@current_shop)
      end
    end

    private
      def set_zone
        @zone = @current_shop.zones.find(params[:id])
      end

      def zone_params
        params.require(:zone).permit(:name, :parent_zone_id, :branch_ids_string)
      end
  end
end
