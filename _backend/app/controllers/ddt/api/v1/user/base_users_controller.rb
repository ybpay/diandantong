module Ddt
  module Api
    module V1
      module Backend
        class BaseUsersController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_base_user, only: [:show, :update]
          check_permission :shop, :base_user, {
            [:index, :normal_users, :vip_users, :show] => :show,
            :update => :update,
            :wallet_logs => :show,
            :recharge_orders => :show
          }

          def index
            base_users = @shop.base_users.includes(:unique_user, vip_info: :vip_level)
                        .ransack(params[:q]).result(distinct: true)
            render_paginated(base_users)
          end

          def normal_users
            base_users = @shop.base_users.of_normal_users.includes(:unique_user, vip_info: :vip_level)
                        .ransack(params[:q]).result(distinct: true)
            render_paginated(base_users)
          end

          def vip_users
            base_users = @shop.base_users.of_vip_users.includes(:unique_user, vip_info: :vip_level)
                        .ransack(params[:q]).result(distinct: true)
            render_paginated(base_users)
          end

          def show
            render_resource(@base_user)
          end

          def update
            if @base_user.update(base_user_params)
              render_resource(@base_user)
            else
              render_errors(@base_user.errors)
            end
          end

          ALLOWED_WALLET_TYPES = %w[card credits branch user].freeze

          def wallet_logs
            wallet_type = params[:wallet_type]
            unless wallet_type.in?(ALLOWED_WALLET_TYPES)
              raise ActionController::BadRequest, "Invalid wallet_type"
            end

            wallet = @base_user.send("#{wallet_type}_wallet")
            raise ActionController::ParameterMissing, "wallet_type" unless wallet
            logs = wallet.wallet_logs.ransack(params[:q]).result.order(created_at: :desc)
            render_paginated(logs)
          end

          def recharge_orders
            orders = @base_user.recharge_orders.ransack(params[:q]).result(distinct: true)
            render_paginated(orders)
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_base_user
            @base_user = @shop.base_users.find(params[:id])
          end

          def base_user_params
            params.require(:base_user).permit(:name, :phone, :is_blocked)
          end
        end
      end
    end
  end
end
