module Ddt
  module Backend
    module BaseWalletsController
      extend ActiveSupport::Concern
      included do
        before_action :set_wallet, only: [:wallet_logs]
      end

      def wallet_logs
        collection = @wallet.wallet_logs
        @q = collection.ransack(params[:q])
        @wallet_logs = @q.result.paginate(page: params[:page])
      end

      private
      def set_wallet
        @wallet = @current_shop.send(controller_name).find(params[:id])
      end
    end
  end
end