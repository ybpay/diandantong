module Ddt
  module Api
    module Admin
      module V1
        class QueueSettingsController < BaseController
          before_action :set_queue_setting, only: [:show, :update, :destroy]

          def index
            queue_settings = scope.ransack(params[:q]).result
            render_paginated(queue_settings)
          end

          def show
            render_resource(@queue_setting)
          end

          def create
            queue_setting = scope.build(queue_setting_params)
            if queue_setting.save
              render_resource_created(queue_setting)
            else
              render_errors(queue_setting.errors)
            end
          end

          def update
            if @queue_setting.update(queue_setting_params)
              render_resource(@queue_setting)
            else
              render_errors(@queue_setting.errors)
            end
          end

          def destroy
            @queue_setting.destroy
            render_empty_success(message: "排队设置已删除")
          end

          private

          def scope
            if params[:branch_id]
              current_shop.branches.find(params[:branch_id]).queue_settings
            else
              Ddt::QueueSetting.joins(:branch).where(branches: { shop_id: current_shop.id })
            end
          end

          def set_queue_setting
            @queue_setting = scope.find(params[:id])
          end

          def queue_setting_params
            params.require(:queue_setting).permit(
              :name, :guest_num_le, :start_at, :end_at,
              :queue_no_prefix, :enabled, :notify_number_in_advance
            )
          end
        end
      end
    end
  end
end
