module Ddt
  module Backend
    class Admin::ShortMessagesController < Ddt::Backend::BaseAdminController
      check_permission :shop, :short_message_setting, :show
      before_action :set_short_message, only: [:show]

      def index
        if @current_account.is_admin? && @current_shop.blank?
          @q = Ddt::ShortMessage.ransack(params[:q])
          @short_messages = @q.result.paginate(page: params[:page])
        else
          @q = @current_shop.short_messages.ransack(params[:q])
          @short_messages = @q.result.paginate(page: params[:page])
        end
      end

      def show
      end

      private
        def set_short_message
          @short_message = @current_shop.short_messages.find(params[:id])
        end

        def short_message_params
          params.require(:short_message).permit(:to, :body, :message_id, :date_created, :type, :size)
        end
    end
  end
end
