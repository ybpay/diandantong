module Ddt
  module Backend
    class SubtractReasonsController < ::Ddt::Backend::BaseController
      check_permission :shop, :subtract_reason
      layout 'ddt/layouts/backend/shop'
      before_action :set_subtract_reason, only: [:show, :edit, :update, :destroy]
      def index
        @subtract_reasons = @current_shop.subtract_reasons
      end

      def show

      end

      def new
        @subtract_reason = @current_shop.subtract_reasons.build
        respond_to do |format|
          format.js
        end
      end

      def create
        @subtract_reason = @current_shop.subtract_reasons.build(subtract_reason_params)
        respond_to do |format|
          format.js do
            if @subtract_reason.save
              render :create
            else
              render :new
            end
          end
        end
      end

      def edit
        respond_to do |format|
          format.js
        end
      end

      def update
        if @subtract_reason.update(subtract_reason_params)
          @subtract_reason.change_position(params[:position])
          render :update
        else
          render :edit
        end
      end

      def destroy
        @subtract_reason.destroy
        respond_to do |format|
          format.js
        end
      end

      private
      def subtract_reason_params
        params.require(:subtract_reason).permit(:name)
      end

      def set_subtract_reason
        @subtract_reason = @current_shop.subtract_reasons.find(params[:id])
      end
    end
  end
end