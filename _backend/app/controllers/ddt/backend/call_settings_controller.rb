module Ddt
  class Backend::CallSettingsController < Backend::BaseController
    check_permission :shop, :call_setting, { show: :show, [:edit, :update] => :update}
    before_action :set_call_setting, only: [:show, :edit, :update]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/call_setting' }
    def show
    end

    def edit

    end

    def update
      if @call_setting.update(call_setting_params)
        flash[:notice] = '呼叫设置修改成功'
        redirect_to [:backend, @current_shop, :call_setting]
      else
        render 'edit'
      end
    end

    private

    def set_call_setting
      @call_setting = @current_shop.call_setting
    end

    def call_setting_params
      if current_account.is_admin?
        params.require(:call_setting).permit(:enable_order_call, :amount)
      else
        params.require(:call_setting).permit(:enable_order_call)
      end
    end
  end
end
