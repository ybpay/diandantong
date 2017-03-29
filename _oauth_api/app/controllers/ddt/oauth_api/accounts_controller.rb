module Ddt
  module OauthApi
    class AccountsController < OauthApi::BaseController
      def show
        render json: {
          id:                 current_account.id,
          name:               current_account.name,
          email:              current_account.email,
          login_id:           current_account.login_id,
          encrypted_password: current_account.encrypted_password,
          shop_id:            current_account.shop_id,
          shop_name:          current_account.shop.name,
          shop_slug:          current_account.shop.slug,
          roles:              current_account.roles.map(&:name),
          all_branches:       current_account.shop.branches.map{|branch| branch.as_json(only: [:id, :name])},
          manage_branches:    current_account.manage_branches.map{|branch| branch.as_json(only: [:id, :name])},
        }
      end
    end
  end
end
