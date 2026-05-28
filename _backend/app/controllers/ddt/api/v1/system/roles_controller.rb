module Ddt
  module Api
    module V1
      module Backend
        class RolesController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_role, only: [:show, :update, :destroy]
          before_action :check_builtin, only: [:update, :destroy]

          def index
            roles = @shop.roles.ransack(params[:q]).result.distinct
            render_paginated(roles)
          end

          def show
            render_resource(@role)
          end

          def create
            role = @shop.roles.custom.build(role_params)
            if role.save
              render_resource_created(role)
            else
              render_errors(role.errors)
            end
          end

          def update
            if @role.update(role_params)
              render_resource(@role)
            else
              render_errors(@role.errors)
            end
          end

          def destroy
            @role.destroy
            render_empty_success(message: "角色已删除")
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_role
            @role = @shop.roles.find(params[:id])
          end

          def check_builtin
            if @role.builtin?
              render json: { errors: [{ status: 403, detail: "系统角色不允许修改" }] }, status: :forbidden
              return
            end
          end

          def role_params
            columns = [:display_name, :description] + Ddt::Role.permission_methods
            params.require(:role).permit(*columns)
          end
        end
      end
    end
  end
end
