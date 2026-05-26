module Ddt
  module Api
    module V1
      module Common
        class SessionsController < Ddt::Api::V1::PublicController
          def create
            account = Account.where(
              ["lower(login_id) = :value OR lower(email) = :value", { value: params[:login_id].to_s.downcase }]
            ).first

            unless account&.valid_password?(params[:password])
              return render json: {
                errors: [{ status: 401, title: "认证失败", code: "AUTH_FAILED" }]
              }, status: :unauthorized
            end

            render json: {
              data: {
                id: account.id,
                login_id: account.login_id,
                name: account.name,
                authentication_token: account.authentication_token,
                shop_id: account.shop&.id
              }
            }
          end

          def destroy
            if current_account
              current_account.update_column(:authentication_token, SecureRandom.hex(16))
            end
            render_empty_success(message: "已退出登录")
          end
        end
      end
    end
  end
end
