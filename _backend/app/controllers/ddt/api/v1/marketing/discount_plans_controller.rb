module Ddt
  module Api
    module V1
      module Backend
        class DiscountPlansController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_discount_plan, only: [:show, :update, :destroy]

          def index
            discount_plans = @branch.discount_plans.ransack(params[:q]).result.distinct
            render_paginated(discount_plans)
          end

          def show
            render_resource(@discount_plan, serializer: ->(dp) {
              dp.as_json(include: [:items])
            })
          end

          def create
            discount_plan = @branch.discount_plans.build(discount_plan_params)
            if discount_plan.save
              render_resource_created(discount_plan)
            else
              render_errors(discount_plan.errors)
            end
          end

          def update
            if @discount_plan.update(discount_plan_params)
              @discount_plan.touch
              render_resource(@discount_plan)
            else
              render_errors(@discount_plan.errors)
            end
          end

          def destroy
            @discount_plan.destroy
            render_empty_success(message: "折扣方案已删除")
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_discount_plan
            @discount_plan = @branch.discount_plans.find(params[:id])
          end

          def discount_plan_params
            params.require(:discount_plan).permit(
              :name, :start_at, :end_at,
              :enable_on_monday, :enable_on_tuesday, :enable_on_wednesday,
              :enable_on_thursday, :enable_on_friday, :enable_on_saturday, :enable_on_sunday,
              discount_plan_items_attributes: [:id, :item_type, :discount, :category_ids_string, :variant_ids_string, :combo_ids_string, :_destroy]
            )
          end
        end
      end
    end
  end
end
