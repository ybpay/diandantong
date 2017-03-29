module Ddt
  class Backend::Wallet::ShopCardWalletsController < Backend::BaseController
    check_permission :shop, :card_wallet, :manage
    layout lambda { params[:layout_name] || 'ddt/layouts/backend/card_wallet' }
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
      collection = @current_shop.wallet_logs.card
      @q = collection.ransack(params[:q])
      @wallet_logs = @q.result.paginate(page: params[:page])
    end

    private
    def set_wallet
      @wallet = @current_shop.card_wallet
    end
  end
end