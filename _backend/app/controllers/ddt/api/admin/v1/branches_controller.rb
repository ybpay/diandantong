module Ddt
  module Api
    module Admin
      module V1
        class BranchesController < BaseController
          before_action :set_branch, only: [:show, :update]

          def index
            branches = current_shop.branches.ransack(params[:q]).result
            render_paginated(branches)
          end

          def show
            render_resource(@branch)
          end

          def create
            branch = current_shop.branches.build(branch_params)
            if branch.save
              render_resource_created(branch)
            else
              render_errors(branch.errors)
            end
          end

          def update
            if @branch.update(branch_params)
              render_resource(@branch)
            else
              render_errors(@branch.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:id])
          end

          def branch_params
            params.require(:branch).permit(:name, :address, :phone, :is_open, :position)
          end
        end
      end
    end
  end
end
