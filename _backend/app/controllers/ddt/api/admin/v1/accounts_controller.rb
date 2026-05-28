module Ddt
  module Api
    module Admin
      module V1
        class AccountsController < BaseController
          before_action :set_account, only: [:show, :update, :destroy]

          def index
            accounts = current_shop.accounts.ransack(params[:q]).result
            render_paginated(accounts)
          end

          def show
            render_resource(@account)
          end

          def create
            account = current_shop.accounts.build(account_params)
            if account.save
              render_resource_created(account)
            else
              render_errors(account.errors)
            end
          end

          def update
            if @account.update(account_params)
              render_resource(@account)
            else
              render_errors(@account.errors)
            end
          end

          def destroy
            @account.destroy
            render_empty_success(message: "账号已删除")
          end

          private

          def set_account
            @account = current_shop.accounts.find(params[:id])
          end

          def account_params
            params.require(:account).permit(:name, :email, :phone, :role_id, :password, :password_confirmation)
          end
        end
      end
    end
  end
end
