module Ddt
  module Api
    module V1
      class AuthController < Ddt::Api::V1::PublicController
        def login
          account = Account.where(
            ["lower(login_id) = :value OR lower(email) = :value", { value: params[:login_id].to_s.downcase }]
          ).first

          unless account&.valid_password?(params[:password])
            return render json: {
              errors: [{ status: 401, title: "认证失败", code: "AUTH_FAILED", detail: "用户名或密码错误" }]
            }, status: :unauthorized
          end

          render json: {
            data: {
              id: account.id,
              login_id: account.login_id,
              email: account.email,
              name: account.name,
              authentication_token: account.authentication_token,
              is_admin: account.is_admin?,
              shop_id: account.shop&.id,
              shop_name: account.shop&.name
            }
          }
        end

        def me
          return render_unauthorized unless @current_account

          account = @current_account
          render json: {
            data: {
              id: account.id,
              login_id: account.login_id,
              email: account.email,
              name: account.name,
              phone: account.phone,
              is_admin: account.is_admin?,
              shop_id: account.shop&.id,
              shop_name: account.shop&.name,
              role: account.role
            }
          }
        end
      end
    end
  end
end
