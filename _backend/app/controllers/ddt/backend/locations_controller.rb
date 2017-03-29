module Ddt
  module Backend
    class LocationsController < Backend::BaseController
      check_permission :shop, :account, :show
      before_action :set_account, only: [:index]
      def index
        @q = @account.locations.order(created_at: :desc).ransack(params[:q])
        @locations = @q.result(distinct: true).paginate(page: params[:page])
      end

      private
        def set_account
          @account = @current_shop.accounts.find(params[:account_id])
        end
    end
  end
end