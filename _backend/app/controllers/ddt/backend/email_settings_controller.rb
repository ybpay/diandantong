module Ddt
  module Backend
    class EmailSettingsController < Backend::BaseController
      check_permission :shop, :email_setting, {show: :show, [:edit, :update, :test] => :update}
      before_action :set_email_setting, only: [:show, :edit, :update, :test]
      def show

      end

      def edit
        @email_setting.address = 'smtp.qq.com'
      end

      def update
        @email_setting.update(email_setting_params)
        flash[:notice] = '邮件设置修改成功'
        redirect_to backend_shop_email_setting_path(@current_shop)
      end

      def test
        if params[:test][:email].present?
          mail = NotificationMailer.notify(params[:test][:email], '测试邮件', '测试邮件', @current_shop)
          mail.deliver
          flash[:notice] = '请检查接收邮箱是否收到测试邮件.'
        end
        redirect_to backend_shop_email_setting_path(@current_shop)
      end

      private
      def set_email_setting
        @email_setting = @current_shop.email_setting
      end

      def email_setting_params
        params.require(:email_setting).permit(:address, :user_name, :password)
      end
    end
  end
end