module Ddt
  module InnerApi
    class AccountsController < InnerApi::BaseController
      def authenticate
        if params[:login_id].present? 
          @account = Ddt::Account.find_by(login_id: params[:login_id])
          if @account.present? && 
            @account.valid_password?(params[:password])
            if params[:role].present? && !@account.send("is_#{params[:role]}?")
              render json: {error: "角色不满足条件"},status: :bad_request
            else
              render :authenticate
            end
          else
            render json: {error: "密码错误"}, status: :bad_request
          end
        else
          render json: {error: "login_id不能为空"}, status: :bad_request
        end
      end
    end
  end
end