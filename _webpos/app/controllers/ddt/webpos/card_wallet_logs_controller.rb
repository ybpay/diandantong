module Ddt
  module Webpos
    class CardWalletLogsController < Webpos::BaseController
      def change_note
        @vip_info = @current_shop.vip_infos.find(params[:vip_info_id])
        @card_wallet_log = @vip_info.card_wallet.logs.find(params[:id])
        @card_wallet_log.change_note(params[:note])
        render :show
      end
    end
  end
end
