module Ddt
  class Backend::TickAccountsController < Backend::BaseController
    check_permission :branch, :tick_account
    before_action :set_tick_account, only: [:edit, :destroy, :update]
    layout 'ddt/layouts/backend/branch'

    def index
      @q = @current_branch.tick_accounts.ransack(params[:q])
      @tick_accounts = @q.result.distinct.paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {
          render json: @tick_accounts.map(&:select_json)
        }
      end
    end

    def new
      @tick_account = @current_branch.tick_accounts.build
    end

    def create
      @tick_account = @current_branch.tick_accounts.build(tick_account_params)
      if @tick_account.save
        redirect_to [:backend, @current_shop, @current_branch, :tick_accounts]
      else
        render :new
      end
    end

    def edit
    end

    def destroy
      @tick_account.destroy
      redirect_to [:backend, @current_shop, @current_branch, :tick_accounts]
    end

    def update
      if @tick_account.update(tick_account_params)
        @tick_account.touch
        redirect_to [:backend, @current_shop, @current_branch, :tick_accounts]
      else
        render :edit
      end
    end

    private

    def set_tick_account
      @tick_account = @current_branch.tick_accounts.find(params[:id])
    end

    def tick_account_params
      params.require(:tick_account).permit(:name, :note, :enable)
    end

  end
end
