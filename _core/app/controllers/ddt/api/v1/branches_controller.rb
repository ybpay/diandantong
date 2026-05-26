module Ddt
  module Api
    module V1
      class BranchesController < BaseController
        before_action :set_shop
        before_action :set_branch, only: [:show, :update]

        def index
          branches = @shop.branches.ransack(params[:q]).result
          render_paginated(branches)
        end

        def show
          render_resource(@branch)
        end

        def update
          if @branch.update(branch_params)
            render_resource(@branch)
          else
            render_errors(@branch.errors)
          end
        end

        private

        def set_shop
          @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
        end

        def set_branch
          @branch = @shop.branches.find(params[:id])
        end

        def branch_params
          params.require(:branch).permit(
            :name, :phone, :address, :description,
            :is_in_service, :contact_name, :province, :city, :district
          )
        end
      end
    end
  end
end
