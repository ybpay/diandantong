module Ddt
  module Backend
    module BaseOrderController
      extend ActiveSupport::Concern
      included do
        before_action :set_order_type
        before_action :set_order_collection
        before_action :set_order
        etag{ current_account.id }
      end

      def show
        fresh_when(@order)
      end

      def pay_by_default_method
        @order.pay_by_default_method
        respond_to do |format|
          format.js do
            if @order.errors.present?
              render '/ddt/backend/order/errors'
            else
              render '/ddt/backend/order/reset_table_tr'
            end
          end
        end
      end

      [:confirm, :complete].each do |action_name|
        module_eval <<-code
          def #{action_name}
            @order.#{action_name}
            respond_to do |format|
              format.html do
                flash[:error] = @order.errors.full_messages if @order.errors.present?
                redirect_to [:backend, @current_shop, @order.branch, @order]
              end
              format.js do
                if @order.errors.present?
                  render '/ddt/backend/order/errors'
                else
                  render '/ddt/backend/order/reset_table_tr'
                end
              end
            end
          end
        code
      end

      def cancel
        @order.cancel(params[:cancel_reason])
        respond_to do |format|
          format.html do
            flash[:error] = @order.errors.full_messages if @order.errors.present?
            redirect_to [:backend, @current_shop, @order.branch, @order]
          end
          format.js do
            if @order.errors.present?
              render '/ddt/backend/order/errors'
            else
              render '/ddt/backend/order/reset_table_tr'
            end
          end
        end
      end

      def other_msg
        respond_to do |format|
          format.js { render '/ddt/backend/order/other_msg'}
        end
      end

      def get_reprint
        respond_to do |format|
          format.js { render '/ddt/backend/order/get_reprint'}
        end
      end

      def chooseable_printers
        @printers = @current_branch.printers.active
        respond_to do |format|
          format.json {
            render :json => @printers.map(&:select_json)
          }
        end
      end

      def reprint
        @order.reprint(params[:target_ids].split(","), params[:note], current_account)
        render js: "bootbox.hideAll(); bootbox.alert('小票补打成功');"
      end

      def get_append_pay_item
        respond_to do |format|
          format.js { render '/ddt/backend/order/get_append_pay_item'}
        end
      end

      def append_pay_item
        if current_account.is_boss? || current_account.is_admin?
          p = params[:append_pay_item]
          pay_itemable = OrderService::PayItemable.new(pay_method_id: p[:pay_method_id], amount: p[:amount].to_f, shop: @current_shop)
          @order.append_pay_item(pay_itemable, p[:description])
          redirect_to [:backend, @current_shop, @order.branch, @order]
        else
          redirect_to [:backend, @current_shop, @order.branch, @order], alert: "权限不足"
        end
      end

      def destroy_pay_item
        if current_account.is_boss? || current_account.is_admin?
          @order.destroy_pay_item(params[:pay_item_id])
          redirect_to [:backend, @current_shop, @order.branch, @order]
        else
          redirect_to [:backend, @current_shop, @order.branch, @order], alert: "权限不足"
        end
      end

      def clear_appended
        if current_account.is_boss? || current_account.is_admin?
          @order.clear_appended
          redirect_to [:backend, @current_shop, @order.branch, @order]
        else
          redirect_to [:backend, @current_shop, @order.branch, @order], alert: "权限不足"
        end
      end

      private
      def set_order_type
        @order_type = controller_name.singularize
      end

      def set_order_collection
        @order_collection = @current_branch.send(controller_name)
      end

      def set_order
        @order = @order_collection.includes_all.find(params[:id])
        @order.operator = current_account
      end

    end
  end
end
