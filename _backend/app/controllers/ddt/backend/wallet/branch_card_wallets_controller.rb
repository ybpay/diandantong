module Ddt
  class Backend::Wallet::BranchCardWalletsController < Backend::BaseController
    check_permission :shop, :card_wallet, :manage
    include Backend::BaseWalletsController
    before_action :set_wallet, only: [:wallet_logs, :get_clearing, :clearing]
    def get_clearing
      @clearing = Ddt::WalletActions::Clearing.new
      respond_to do |format|
        format.js
      end
    end

    def clearing
      @clearing = Ddt::WalletActions::Clearing.new(params[:wallet_actions_clearing].merge(wallet: @wallet))
      respond_to do |format|
        format.js do
          if @clearing.valid?
            @clearing.perform
            render :reset_tr
          else
            render :get_clearing
          end
        end
      end
    end
  end
end