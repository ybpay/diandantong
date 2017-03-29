module Ddt
  module CommonApi
    module V1
      class CreditsWalletsController < V1::BaseController

        before_action :set_vip_info

        def recharge
          @wallet = @vip_info.credits_wallet
          @get = Ddt::WalletActions::Get.new(params[:recharge].merge(wallet: @wallet, operator: current_account, branch: current_branch))
          if @get.valid?
            @get.perform
            render file: 'ddt/common_api/v1/vip_infos/show'
          else
            render json: { errors: @get.errors.full_messages }, status: :bad_request
          end
        end

        def exchange
          @wallet = @vip_info.credits_wallet
          @exchange = Ddt::WalletActions::Exchange.new(params[:exchange].merge(wallet: @wallet, operator: current_account, branch: current_branch))
          if @exchange.valid?
            @exchange.perform
            render file: 'ddt/common_api/v1/vip_infos/show'
          else
            render json: { errors: @exchange.errors.full_messages }, status: :bad_request
          end
        end


        private

          def set_vip_info
            @vip_info = @current_shop.vip_infos.find(params[:vip_info_id])
          end


      end
    end
  end
end
