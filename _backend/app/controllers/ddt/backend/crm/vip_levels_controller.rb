module Ddt
  module Backend
    module Crm
      class VipLevelsController < Backend::BaseCrmController
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
            render :show
          else
            render json: { errors: @vip_level.errors.full_messages }, status: :bad_request
          end
        end

        def update
          if @vip_level.update(vip_level_params)
            render :show
          else
            render json: { errors: @vip_level.errors.full_messages }, status: :bad_request
          end
        end

        def destroy
          if @vip_level.destroy
            render json: {}
          else
            render json: { errors: @vip_level.errors.full_messages }, status: :bad_request
          end
        end

        private
          def set_vip_level
            @vip_level = @current_shop.vip_levels.find(params[:id])
          end

          def vip_level_params
            params.require(:vip_level).permit(:name, :level, :discount, :auto_upgrade,
              :upgrade_recharge_money, :upgrade_total_amount, :upgrade_get_credits)
          end
      end
    end
  end
end
