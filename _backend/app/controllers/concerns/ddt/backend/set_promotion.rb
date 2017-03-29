module Ddt
  module Backend
    module SetPromotion
      extend ActiveSupport::Concern
      included do
        before_action :set_promotion_owner
        before_action :set_promotion_type
        before_action :set_promotion_collection
        before_action :set_promotion
      end

      private

      def set_promotion_owner
        @promotion_owner = @current_branch.present? ? @current_branch : @current_shop
      end

      def set_promotion_type
        if controller_name.to_sym == :order_promotions || params[:order_promotion_id].present?
          @promotion_type = :order_promotion
        elsif controller_name.to_sym == :event_promotions || params[:event_promotion_id].present?
          @promotion_type = :event_promotion
        elsif controller_name.to_sym == :product_promotions || params[:product_promotion_id].present?
          @promotion_type = :product_promotion
        end
        @promotion_type_prefix = @promotion_type.to_s.gsub('_promotion', '')
        @promotion_type
      end

      def promotion_type
        @promotion_type ||= set_promotion_type
      end

      def set_promotion_collection
        @promotion_collection = @promotion_owner.send(@promotion_type.to_s.pluralize)
      end

      def set_promotion
        params_id = params[:order_promotion_id] || params[:event_promotion_id] || params[:product_promotion_id] || params[:id]
        @promotion = @promotion_collection.find(params_id) if params_id
      end
    end
  end
end