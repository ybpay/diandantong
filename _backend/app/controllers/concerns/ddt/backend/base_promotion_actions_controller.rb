module Ddt
  module Backend
    module BasePromotionActionsController
      extend ActiveSupport::Concern
      included do
        include Backend::SetPromotion
      end

      def index
        render "ddt/backend/_promotion/actions/index", layout: 'ddt/layouts/backend/promotion'
      end

      def create
        promotion_action_type = params[:promotion_action].delete(:type)
        @promotion_action = promotion_action_type.constantize.new(params[:promotion_action])
        @promotion_action.promotion = @promotion
        if @promotion_action.save
          flash[:success] = I18n.t(:successfully_created, resource: I18n.t('activerecord.models.ddt/promotion_action'))
        end
        respond_to do |format|
          format.html { redirect_to [:edit, :backend, @current_shop, @promotion.branch, @promotion].compact}
          format.js { render "ddt/backend/_promotion/actions/create", layout: false }
        end
      end

      def destroy
        @promotion_action = @promotion.promotion_actions.find(params[:id])
        if @promotion_action.destroy
          flash[:success] = I18n.t(:successfully_destroyed, resource: I18n.t('activerecord.models.ddt/promotion_action'))
        end
        respond_to do |format|
          format.html { redirect_to [:edit, :backend, @current_shop, @promotion.branch, @promotion].compact}
          format.js { render "ddt/backend/_promotion/actions/destroy", layout: false }
        end
      end


    end
  end
end