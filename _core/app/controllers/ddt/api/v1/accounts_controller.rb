module Ddt
  module Api
    module V1
      class AccountsController < BaseController
        skip_before_action :authenticate_api_account!, only: [:login, :register]

        def show
          render_resource(current_account)
        end

        def update
          if current_account.update(account_params)
            render_resource(current_account)
          else
            render_errors(current_account.errors)
          end
        end

        def login
          account = Account.where(
            ["lower(login_id) = :value OR lower(email) = :value", { value: params[:login_id].to_s.downcase }]
          ).first

          unless account&.valid_password?(params[:password])
            return render json: {
              errors: [{ status: 401, title: "认证失败", code: "AUTH_FAILED", detail: "用户名或密码错误" }]
            }, status: :unauthorized
          end

          token = account.authentication_token
          render json: {
            data: {
              account: {
                id: account.id,
                login_id: account.login_id,
                email: account.email,
                name: account.name,
                is_admin: account.is_admin?,
                authentication_token: token,
                role: account.role
              },
              shop: account.shop ? {
                id: account.shop.id,
                name: account.shop.name,
                slug: account.shop.slug
              } : nil
            }
          }
        end

        def register
          account = Account.new(account_params.merge(password: params[:password]))
          if account.save
            render_resource_created(account)
          else
            render_errors(account.errors)
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
