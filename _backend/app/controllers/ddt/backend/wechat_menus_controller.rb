module Ddt
  class Backend::WechatMenusController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage

    before_action :set_wechat_account
    before_action :set_wechat_menu, only: [:edit, :update, :destroy, :change_position]
    before_action :check_menu_count, only: [:new]
    layout 'ddt/layouts/backend/wechat_account'


    def index
      @root_wechat_menus = @wechat_account.wechat_menus.root_menus
    end

    def new
      if params[:event_type].present?
        @wechat_menu = @wechat_account.wechat_menus.build(event_type: params[:event_type] ,parent_id: params[:parent_id])
        render :new
      elsif
        render :choose_event_type
      end
    end


    def edit
      respond_to do |format|
        format.js {}
      end
    end

    def create
      @wechat_menu = @wechat_account.wechat_menus.build(fix_params(wechat_menu_params))
      @wechat_menu.shop_id = @current_shop.id
      if @wechat_menu.save
        render :reset
      else
        render :new
      end
    end

    def update
      if @wechat_menu.update(fix_params(wechat_menu_params))
        render :reset
      else
        render :edit
      end
    end

    def destroy
      @wechat_menu.destroy
      render :reset
    end

    def change_position
      @wechat_menu.change_position(params[:position])
      render :reset
    end

    def sync
      @result, @error = @wechat_account.sync_custom_wechat_menu_to_wechat
    end

    private
    def set_wechat_menu
      @wechat_menu = @wechat_account.wechat_menus.find(params[:id])
    end

    def set_wechat_account
      @wechat_account = @current_shop.wechat_accounts.find(params[:wechat_account_id]) rescue nil
    end

    def wechat_menu_params
      params.require(:wechat_menu).permit(:name, :menu_type, :reply_type, :event_type, :parent_id, :material_id, :keyword, :url);
    end

    def fix_params(params)
      if(params[:reply_type]=='system_keyword')
        params[:material_id] = nil
      else
        params[:keyword] = nil
      end
      return params
    end

    def check_menu_count
      if params[:parent_id].present?
        @parent_wechat_menu = @wechat_account.wechat_menus.find_by_id(params[:parent_id])
        if @parent_wechat_menu.present? && @parent_wechat_menu.subs.count >= 5
          render :sub_menus_count_limit
        end
      else
        if @wechat_account.wechat_menus.root_menus.count >= 3
          render :root_menus_count_limit
        end
      end
    end

  end
end