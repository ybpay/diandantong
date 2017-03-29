module Ddt
  module Webpos
    class UserCardWalletsController < Webpos::BaseController
      include BaseWalletController
      respond_to :json
      check_permission :shop, :user, {
        recharge: :recharge_card_wallet,
        exchange: :exchange_card_wallet,
      }

      def recharge
        @recharge = Ddt::WalletActions::Recharge.new(recharge_params.merge(wallet: @wallet, operator: current_account))
        if @recharge.valid?
          @recharge.perform
          @wallet = @recharge.wallet
          render 'show'
        else
          render json: { errors: @recharge.errors.full_messages }, status: :bad_request
        end
      end

      private
        def recharge_params
          params.require(:recharge).permit(:amount, :cash_amount, :note, :branch_id)
        end
    end
  end
end
