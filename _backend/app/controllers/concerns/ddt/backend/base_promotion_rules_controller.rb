module Ddt
  module Backend
    module BasePromotionRulesController
      extend ActiveSupport::Concern
      included do
        include Backend::SetPromotion
      end

      def index
        render "ddt/backend/_promotion/rules/index", layout: 'ddt/layouts/backend/promotion'
      end

      def create
        promotion_rule_type = params[:promotion_rule].delete(:type)
        @promotion_rule = promotion_rule_type.constantize.new(params[:promotion_rule])
        @promotion_rule.promotion = @promotion
        if @promotion_rule.save
          flash[:success] = I18n.t(:successfully_created, resource: I18n.t('activerecord.models.ddt/promotion_rule'))
        end
        respond_to do |format|
          format.html { redirect_to [:edit, :backend, @current_shop, @promotion.branch, @promotion].compact}
          format.js { render "ddt/backend/_promotion/rules/create", layout: false }
        end
      end

      def destroy
        @promotion_rule = @promotion.promotion_rules.find(params[:id])
        if @promotion_rule.destroy
          flash[:success] = I18n.t(:successfully_destroyed, resource: I18n.t('activerecord.models.ddt/promotion_rule'))
        end
        respond_to do |format|
          format.html { redirect_to [:edit, :backend, @current_shop, @promotion.branch, @promotion].compact}
          format.js   { render "ddt/backend/_promotion/rules/destroy", layout: false }
        end
      end


    end
  end
end