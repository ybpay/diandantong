module Ddt
  module Api
    module V1
      module Common
        class AccountsController < Ddt::Api::V1::BaseController
          skip_before_action :authenticate_api_account!, only: [:create]
          skip_before_action :set_shop_context, only: [:create]
          skip_before_action :check_shop_ban, only: [:create]

          def show
            render_resource(current_account)
          end

          def create
            account = Account.new(account_params)
            if account.save
              render_resource_created(account)
            else
              render_errors(account.errors)
            end
          end

          def update_password
            unless current_account.valid_password?(params[:current_password])
              return render json: { errors: [{ status: 400, title: "当前密码不正确" }] }, status: :bad_request
            end

            if current_account.update(password: params[:password], password_confirmation: params[:password_confirmation])
              render_empty_success(message: "密码修改成功")
            else
              render_errors(current_account.errors)
            end
          end

          private

          def account_params
            params.require(:account).permit(:login_id, :email, :name, :phone, :password, :password_confirmation)
          end
        end
      end
    end
  end
end
