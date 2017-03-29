module Ddt
  module Weixin
    module BaseCartController
      extend ActiveSupport::Concern
      included do
        respond_to :json
        before_action :set_cart
        before_action :set_line_itemable, only: [:add_itemable, :remove_itemable]
        after_action :store_cart
      end

      def show
      end

      def add_itemable
        @cart.add(@line_itemable)
        after_add_itemable
        @cart.update_discount
        render :show
      end

      def remove_itemable
        @cart.remove(@line_itemable)
        after_remove_itemable
        @cart.update_discount
        render :show
      end

      def clear
        @cart.clear
        after_clear_cart
        @cart.update_discount
        render :show
      end

      def update_cart
        line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
        @cart.update_line_items(line_itemables)
        @cart.update_discount
        render :show
      end

      def add_combo_package
        @combo = Combo.find(params[:combo_package][:combo_id])
        @combo_package = @combo.add_combo_package(params[:combo_package][:items])
        if @combo_package.present?
          if @cart.add(@combo_package.to_line_itemable)
            @cart.update_discount
            after_add_combo_package_to_cart
            render :show
          else
            render json: { errors: @cart.errors.full_messages }, status: :bad_request
          end
        else
          render json: { errors: @combo.errors.full_messages }, status: :bad_request
        end
      end

      def after_clear_cart
      end

      def after_add_itemable
      end

      def after_remove_itemable
      end

      def after_add_combo_package_to_cart
      end

      private
      def set_cart
        @cart_type = controller_name.gsub('_carts', '')
        @cart_session_key = "#{@branch.id}_#{@cart_type}"
        @cart = OrderService::Cart.const_get(@cart_type.classify).init_from_session(@branch, @current_user, session[@cart_session_key], track_from: @track_from)
      end

      def set_line_itemable
        @line_itemable = OrderService::LineItemable.new(
          itemable_type: params[:itemable_type],
          itemable_id: params[:itemable_id],
          note: params[:note],
        )
      end

      def store_cart
        session[@cart_session_key] = @cart.to_session
      end

    end
  end
end
