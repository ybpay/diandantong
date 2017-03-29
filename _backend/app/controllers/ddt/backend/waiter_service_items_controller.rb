module Ddt
  module Backend
    class WaiterServiceItemsController < Ddt::Backend::BaseController
      check_permission :branch, :waiter_service_item
      before_action :set_waiter_service_item, only: [:edit, :update, :destroy]
      layout 'ddt/layouts/backend/branch'


      def index
        @q = @current_branch.waiter_service_items.ransack(params[:q])
        @waiter_service_items = @q.result.distinct.paginate(page: params[:page])
      end

      def new
        @waiter_service_item = @current_branch.waiter_service_items.build
      end

      def edit
      end

      def create
        @waiter_service_item = @current_branch.waiter_service_items.build(waiter_service_item_params)
        if @waiter_service_item.save
          index
          render 'reset_tbody'
        else
          render :new
        end
      end

      def update
        if @waiter_service_item.update(waiter_service_item_params)
          render 'reset_tr'
        else
          render :edit
        end
      end

      def destroy
        @waiter_service_item.destroy
        respond_to do |format|
          format.js { render 'remove_tr'}
        end
      end

      private
      def waiter_service_item_params
        params.require(:waiter_service_item).permit(:name)
      end

      def set_waiter_service_item
        @waiter_service_item = @current_branch.waiter_service_items.find(params[:id])
      end

    end
  end
end