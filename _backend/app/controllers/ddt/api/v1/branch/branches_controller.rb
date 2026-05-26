module Ddt
  module Api
    module V1
      module Backend
        class BranchesController < Ddt::Api::V1::BaseController
          before_action :set_shop

          def index
            branches = @shop.branches.ransack(params[:q]).result
            render_paginated(branches)
          end

          def show
            branch = @shop.branches.find(params[:id])
            render_resource(branch)
          end

          def create
            branch = @shop.branches.build(branch_params)
            if branch.save
              render_resource_created(branch)
            else
              render_errors(branch.errors)
            end
          end

          def update
            branch = @shop.branches.find(params[:id])
            if branch.update(branch_params)
              render_resource(branch)
            else
              render_errors(branch.errors)
            end
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def branch_params
            params.require(:branch).permit(
              :name, :phone, :address, :description, :contact_name,
              :province, :city, :district, :is_in_service,
              :longitude, :latitude, :business_hours_start, :business_hours_end
            )
          end
        end
      end
    end
  end
end
