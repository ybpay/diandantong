module Ddt
  module Webpos
    module BaseWalletController
      extend ActiveSupport::Concern
      included do
        before_action :set_wallet

        def exchange
          @exchange = Ddt::WalletActions::Exchange.new(exchange_params.merge(wallet: @wallet, operator: current_account))
          if @exchange.valid?
            @exchange.perform
            @wallet = @exchange.wallet
            render 'show'
          else
            render json: { errors: @exchange.errors.full_messages }, status: :bad_request
          end
        end

        private

        def set_wallet
          @wallet = @current_shop.send(controller_name).find(params[:id])
        end

        def exchange_params
          params.require(:exchange).permit(:amount, :note, :branch_id)
        end
      end
    end
  end
end