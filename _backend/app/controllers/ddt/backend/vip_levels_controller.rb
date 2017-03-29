module Ddt
  class Backend::VipLevelsController < Backend::BaseController
    check_permission :shop, :vip_level
    before_action :set_vip_level, only: [:show, :edit, :update, :destroy]

    def index
      @q = @current_shop.vip_levels.ransack(params[:q])
      @vip_levels = @q.result(distinct: true).paginate(page: params[:page])
    end

    def show
    end

    def new
      @vip_level = @current_shop.vip_levels.build
    end

    def edit
    end

    def create
      @vip_level = @current_shop.vip_levels.build(vip_level_params)

      if @vip_level.save
        redirect_to [:backend, @current_shop, @vip_level], notice: "#{t('activerecord.models.ddt/vip_level')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @vip_level.update(vip_level_params)
        redirect_to [:backend, @current_shop, @vip_level], notice: "#{t('activerecord.models.ddt/vip_level')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @vip_level.destroy
        redirect_to backend_shop_vip_levels_url(@current_shop), notice: "#{t('activerecord.models.ddt/vip_level')} 删除成功."
      else
        flash[:error] = @vip_level.errors.full_messages.join('<br/>')
        redirect_to backend_shop_vip_levels_url(@current_shop)
      end
    end

    private
      def set_vip_level
        @vip_level = @current_shop.vip_levels.find(params[:id])
      end

      def vip_level_params
        params.require(:vip_level).permit(:shop_id, :name, :discount, :vip_infos_count, :auto_upgrade,
          :upgrade_recharge_money, :upgrade_total_amount, :upgrade_get_credits, :level)
      end
  end
end
