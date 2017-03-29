module Ddt
  module Webpos
    class UserCreditsWalletsController < Webpos::BaseController
      include BaseWalletController
      respond_to :json
      check_permission :shop, :user, { exchange: :exchange_credits_wallet, get: :get_credits_wallet }

      def get
        @exchange = Ddt::WalletActions::Get.new(get_params.merge(wallet: @wallet, operator: current_account))
        if @exchange.valid?
          @exchange.perform
          @wallet = @exchange.wallet
          render 'show'
        else
          render json: { errors: @exchange.errors.full_messages }, status: :bad_request
        end
      end

      private
      def get_params
        params.require(:get).permit(:amount, :note, :branch_id)
      end
    end
  end
end
