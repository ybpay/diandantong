module Ddt
  class Backend::Wallet::ShopCreditsWalletsController < Backend::BaseController
    check_permission :shop, :credits_wallet, :manage
    layout lambda { params[:layout_name] || 'ddt/layouts/backend/credits_wallet' }
    before_action :set_wallet

    def branches
      collection = @current_shop.branches
      @q = collection.ransack(params[:q])
      @branches = @q.result.paginate(page: params[:page])
    end

    def base_users
      collection = @current_shop.base_users
      @q = collection.ransack(params[:q])
      @base_users = @q.result.paginate(page: params[:page])
    end

    def wallet_logs
      collection = @current_shop.wallet_logs.credits
      @q = collection.ransack(params[:q])
      @wallet_logs = @q.result.paginate(page: params[:page])
    end

    private
    def set_wallet
      @wallet = @current_shop.credits_wallet
    end
  end
end