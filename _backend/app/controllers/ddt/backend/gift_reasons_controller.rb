module Ddt
  module Backend
    class GiftReasonsController < ::Ddt::Backend::BaseController
      check_permission :shop, :gift_reason
      layout 'ddt/layouts/backend/shop'
      before_action :set_gift_reason, only: [:show, :edit, :update, :destroy]
      def index
        @gift_reasons = @current_shop.gift_reasons
      end

      def show

      end

      def new
        @gift_reason = @current_shop.gift_reasons.build
        respond_to do |format|
          format.js
        end
      end

      def create
        @gift_reason = @current_shop.gift_reasons.build(gift_reason_params)
        respond_to do |format|
          format.js do
            if @gift_reason.save
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
        if @gift_reason.update(gift_reason_params)
          @gift_reason.change_position(params[:position])
          render :update
        else
          render :edit
        end
      end

      def destroy
        @gift_reason.destroy
        respond_to do |format|
          format.js
        end
      end

      private
      def gift_reason_params
        params.require(:gift_reason).permit(:name)
      end

      def set_gift_reason
        @gift_reason = @current_shop.gift_reasons.find(params[:id])
      end
    end
  end
end