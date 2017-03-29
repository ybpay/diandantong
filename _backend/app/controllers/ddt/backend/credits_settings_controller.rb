module Ddt
  class Backend::CreditsSettingsController < Backend::BaseController
    check_permission :shop, :credits_setting, {show: :show, [:edit, :update] => :update}
    before_action :set_credits_setting, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/credits_wallet'

    def show
    end

    def edit
    end

    def update
      if @credits_setting.update(credits_setting_params)
        redirect_to [:backend, @current_shop, :credits_setting]
      else
        render 'edit'
      end
    end

    private

    def set_credits_setting
      @credits_setting = @current_shop.credits_setting
    end

    def credits_setting_params
      params.require(:credits_setting).permit(:exchange_radio)
    end
  end
end