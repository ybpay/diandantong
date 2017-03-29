module Ddt
  module Backend
    class SystemMessagesController < ::Ddt::Backend::BaseController
      def index
        @q = @current_account.system_messages.ransack(params[:q])
        @system_messages = @q.result.paginate(page: params[:page])
        respond_to do |format|
          format.html
        end
      end

      def batch_delete_selected
        unless system_message_params[:system_message_ids].blank?
          @current_account.system_messages.where(id: system_message_params[:system_message_ids]).delete_all
          redirect_to backend_shop_system_messages_url(@current_shop), notice: "#{t('activerecord.models.ddt/system_message')} 删除成功."
        else
          flash[:notice] = '请选择要删除的消息！'
        end
      end


      def show
        @system_message = @current_account.system_messages.find(params[:id])
        @system_message.change_to_read
        respond_to do |format|
          format.html
        end
      end

      private
      def system_message_params
        params.require(:system_message).permit(system_message_ids: [])
      end

    end
  end
end