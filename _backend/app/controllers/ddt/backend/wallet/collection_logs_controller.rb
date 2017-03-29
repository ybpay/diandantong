module Ddt
  module Backend
    module Wallet
      class CollectionLogsController < Ddt::Backend::BaseController
        check_permission :shop, :collection_wallet, :show
        layout 'ddt/layouts/backend/alipay_method'
        before_action :set_wallet

        def index
          @q = @wallet.wallet_logs.order(created_at: :desc).ransack(params[:q])
          @wallet_logs = @q.result.paginate(page: params[:page], per_page: 20)
        end

        private
        def set_wallet
          @wallet = @current_shop.collection_wallet
        end
      end
    end
  end
end