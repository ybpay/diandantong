module Ddt
  class Backend::UserWalletsController < Backend::BaseController
    check_permission :shop, :user, :show
    def card_wallets
      @q = @current_shop.user_card_wallets.not_default.ransack(params[:q])
      @wallets = @q.result.paginate(page: params[:page])
      render layout: 'ddt/layouts/backend/statistic/user'
    end

  end
end
