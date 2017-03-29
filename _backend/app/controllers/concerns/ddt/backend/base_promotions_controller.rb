module Ddt
  module Backend
    module BasePromotionsController
      extend ActiveSupport::Concern
      included do
        include Backend::SetPromotion
        respond_to :html
        layout lambda { params[:layout_name]||'ddt/layouts/backend/promotion' }
      end


      def index
        @q = @promotion_collection.ransack(params[:q])
        @promotions = @q.result.distinct.paginate(page: params[:page])
        render "ddt/backend/_promotion/index"
      end

      def new
        @promotion = @promotion_collection.build(starts_at: DateTime.now, expires_at: 1.month.from_now)
        render "ddt/backend/_promotion/new"
      end

      def create
        @promotion = @promotion_collection.build(promotion_params)
        if @promotion.save
          @current_shop.touch
          flash[:success] = I18n.t(:successfully_created, resource: I18n.t("activerecord.models.ddt/#{promotion_type}"))
          redirect_to [:edit, :backend, @current_shop, @promotion.branch, @promotion].compact
        else
          render "ddt/backend/_promotion/new"
        end
      end

      def edit
        render "ddt/backend/_promotion/edit"
      end

      def update
        if @promotion.update(promotion_params)
          @current_shop.touch
          flash[:success] = I18n.t(:successfully_updated, resource: I18n.t("activerecord.models.ddt/#{promotion_type}"))
          redirect_to request.referer #[:edit, :backend, @current_shop, @promotion.branch, @promotion].compact
        else
          render "ddt/backend/_promotion/edit"
        end
      end

      def destroy
        @promotion.destroy
        flash[:success] = I18n.t(:successfully_destroyed, resource: I18n.t("activerecord.models.ddt/#{promotion_type}"))
        redirect_to  [:backend, @current_shop, @promotion.branch, @promotion_type.to_s.pluralize].compact
      end

      private
      def promotion_params
        if params[promotion_type]
          params.require(promotion_type).permit!
        else
          {}
        end
        # params.require(:order_promotion)
        #       .permit(:name, :description, :usage_limit, :starts_at, :expires_at, :match_policy, :type,
        #               promotion_rules_attributes: [:id, :type, :preferred_operator_min, :preferred_operator_max, :preferred_amount_min, :preferred_amount_max],
        #               promotion_actions_attributes: [:id, :type, :calculator_type, calculator_attributes: [:id, :type, :preferred_flat_percent, :preferred_amount, :preferred_first_item, :preferred_additional_item, :preferred_max_items, :preferred_percent, :preferred_base_amount, :preferred_tiers, :preferred_base_percent] ])
      end

      def order_promotion_params
        promotion_params
      end

      def event_promotion_params
        promotion_params
      end
    end
  end
end
