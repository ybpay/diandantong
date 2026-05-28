module Ddt
  module Api
    module V1
      module Backend
        class VipLevelsController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_vip_level, only: [:show, :update, :destroy]

          def index
            vip_levels = @shop.vip_levels.ransack(params[:q]).result.distinct
            render_paginated(vip_levels)
          end

          def show
            render_resource(@vip_level)
          end

          def create
            vip_level = @shop.vip_levels.build(vip_level_params)
            if vip_level.save
              render_resource_created(vip_level)
            else
              render_errors(vip_level.errors)
            end
          end

          def update
            if @vip_level.update(vip_level_params)
              render_resource(@vip_level)
            else
              render_errors(@vip_level.errors)
            end
          end

          def destroy
            @vip_level.destroy
            render_empty_success(message: "VIP等级已删除")
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_vip_level
            @vip_level = @shop.vip_levels.find(params[:id])
          end

          def vip_level_params
            params.require(:vip_level).permit(
              :shop_id, :name, :discount, :vip_infos_count, :auto_upgrade,
              :upgrade_recharge_money, :upgrade_total_amount, :upgrade_get_credits, :level
            )
          end
        end
      end
    end
  end
end
