# encoding: utf-8
module Ddt
  class Agentsys::UsersController < Agentsys::BaseController

    def index
      @wechat_account = Ddt::WechatAccount.system_wechat_account
      @q = @wechat_account.shop.users.includes(:unique_user).ransack(params[:q].try(:merge, m: 'or'))
      @users = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.html{
          render {}
        }
        format.json {
          render :json => @users.map(&:select_json)
        }
      end
    end

  end
end
