module Ddt
  class Backend::TickAccountItemsController < Backend::BaseController
    check_permission :branch, :tick_account, :show
    before_action :set_tick_account
    layout 'ddt/layouts/backend/branch'

    def index
      @q = @tick_account.items.ransack(params[:q])
      @items = @q.result.distinct.paginate(page: params[:page])
      @amount_not_complete = @tick_account.items.by_state(:pending).sum(:amount)
      respond_to do |format|
        format.html
      end
    end

    def complete
      @tick_account_item = @tick_account.items.find(params[:id])
      @tick_account_item.complete
      respond_to do |format|
        format.js
      end
    end

    def batch_complete
      @tick_account.items.by_state(:pending).update_all(state: :completed, updated_at: Time.now)
      redirect_to [:backend, @current_shop, @current_branch, @tick_account, :tick_account_items]
    end

    private

    def set_tick_account
      @tick_account = @current_branch.tick_accounts.find(params[:tick_account_id])
    end

  end
end
