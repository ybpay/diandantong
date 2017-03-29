module Ddt
  module Webpos
    class AccountsController < Webpos::BaseController
      respond_to :json
      def show
        @account = current_account
        fresh_when(@account)
      end

      def get_authorizers
        scope = params[:auth_scope]
        target = params[:auth_target]
        action = params[:auth_action]
        options = JSON.parse(params[:auth_options]).to_options
        roles = @current_shop.roles.select{|role| role.can?(scope, target, action)}
        @bosses = @current_shop.accounts.bosses
        case scope.to_sym
        when :shop
          @accounts = @current_shop.accounts.includes(:roles).where(ddt_roles: { id: roles.map(&:id) }).references(:ddt_roles)
        when :branch
          @accounts = @current_shop.accounts.includes(:roles).where(ddt_roles: { id: roles.map(&:id) }).references(:ddt_roles)
                                            .includes(:manage_branches).where(ddt_branches: { id: options[:branch_id] }).references(:ddt_branches)
        end
        @accounts = (@bosses + @accounts).uniq
        render json: @accounts.map{|account| account.as_json(only: [:id, :name])}
      end

      def bosses_and_workers
        @accounts = @current_shop.accounts.bosses_and_workers
        render :bosses
      end

      def authorization
        @auther = @current_shop.accounts.bosses_and_workers.find(params[:auth_id])
        if @auther.blank? || params[:password].blank?
          render json: {ok: false}
        else
          render json: {ok: (@auther.valid_password? params[:password])}
        end
      end
    end
  end
end
