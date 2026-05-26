module Ddt
  module Api
    module V1
      class AccountsController < BaseController
        skip_before_action :authenticate_api_account!, only: [:register]

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
