module Ddt
  module Backend
    module Crm
      class CardWalletLogsController < Backend::BaseCrmController

        def index
          @vip_info = @current_shop.vip_infos.find(params[:vip_info_id])
          @q = @vip_info.card_wallet.logs.ransack(params[:q])
          @logs = @q.result.paginate(page: params[:page], per_page: (params[:per_page] || 10))
        end
      end
    end
  end
end
