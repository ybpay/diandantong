module Ddt
  module Api
    module Admin
      module V1
        class PromotionsController < BaseController
          before_action :set_promotion, only: [:show, :update, :destroy]

          def index
            promotions = current_shop.event_promotions.ransack(params[:q]).result
            render_paginated(promotions)
          end

          def show
            render_resource(@promotion)
          end

          def create
            promotion = current_shop.event_promotions.build(promotion_params)
            if promotion.save
              render_resource_created(promotion)
            else
              render_errors(promotion.errors)
            end
          end

          def update
            if @promotion.update(promotion_params)
              render_resource(@promotion)
            else
              render_errors(@promotion.errors)
            end
          end

          def destroy
            @promotion.destroy
            render_empty_success(message: "促销活动已删除")
          end

          private

          def set_promotion
            @promotion = current_shop.event_promotions.find(params[:id])
          end

          def promotion_params
            params.require(:promotion).permit(:name, :description, :start_at, :end_at, :enabled)
          end
        end
      end
    end
  end
end
