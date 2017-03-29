module Ddt
  class Backend::Wallet::UserCreditsWalletsController < Backend::BaseController
    check_permission :shop, :user, {
      [:get_exchange, :exchange] => :exchange_credits_wallet,
      wallet_logs: :show
    }
    include Backend::BaseWalletsController
    before_action :set_wallet, only: [:wallet_logs, :get_exchange, :exchange]
    def get_exchange
      @exchange = Ddt::WalletActions::Exchange.new
      respond_to do |format|
        format.js
      end
    end

    def exchange
      @exchange = Ddt::WalletActions::Exchange.new(params[:wallet_actions_exchange].merge(wallet: @wallet, operator: current_account))
      respond_to do |format|
        format.js do
          if @exchange.valid?
            @exchange.perform
            render :reset_tr
          else
            render :get_exchange
          end
        end
      end
    end
  end
end