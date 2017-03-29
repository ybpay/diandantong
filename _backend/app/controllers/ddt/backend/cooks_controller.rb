module Ddt
  module Backend
    class CooksController < Ddt::Backend::BaseController
      check_permission :branch, :cook, :manage
      layout 'ddt/layouts/backend/branch'
      before_action :set_cook, only: [:edit, :update]

      def index
        @cooks = @current_branch.managers.cooks
      end

      def edit
      end

      def update
        @cook.update(cook_params)
        respond_to do |format|
          format.js {render 'reset_tr'}
        end
      end

      private

        def set_cook
          @cook = @current_branch.managers.cooks.find(params[:id])
        end

        def cook_params
          params.require(:account).permit(:product_ids_string, :category_ids_string)
        end
    end
  end
end