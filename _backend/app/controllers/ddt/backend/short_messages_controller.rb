module Ddt
  class Backend::ShortMessagesController < Backend::BaseController
    check_permission :shop, :short_message_setting, :show
    before_action :set_short_message, only: [:show]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/short_message' }

    def index
      @q = @current_shop.short_messages.ransack(params[:q])
      @short_messages = @q.result.paginate(page: params[:page])
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
