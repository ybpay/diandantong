module Ddt
  class Backend::AccountsController < Backend::BaseController
    check_permission :shop, :account, base_permission_actions.merge({
      [:get_bind, :bind, :unbind, :unlock, :edit_password, :update_password] => :update,
    })
    before_action :set_account_collection, except: [:new, :create]
    before_action :set_account, only: [:show, :edit, :update, :unlock, :destroy, :edit_password, :update_password, :bind, :get_bind, :unbind]
    layout 'ddt/layouts/backend/accounts'
    def index
      @q = @collection.ransack(params[:q])
      @accounts = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.html { render layout: 'ddt/layouts/backend' }
        format.json { render json: @accounts.map(&:select_json) }
      end
    end

    def new
      @account = @current_shop.accounts.build
      render layout: 'ddt/layouts/backend'
    end

    def create
      @account = @current_shop.accounts.build(account_params)
      @account.captcha_valid = true
      if @account.save
        redirect_to [:backend, @current_shop, @account], notice: "#{t('activerecord.models.ddt/account')} 创建成功."
      else
        render :new, layout: 'ddt/layouts/backend'
      end
    end

    def get_bind
      @mode = params[:mode] || 'scan'
      @appid = Ddt::WeixinConfig.webauth.app_id
    end

    def bind
      if params[:mode] == 'scan'
        if params[:code]
          result = @account.bind_by_code(params[:code])
        else
          result = false
        end
      elsif params[:mode] == 'manual'
        user_id = Integer(params[:user_id]) rescue nil
        if user_id
          result = @account.bind_by_user_id(user_id)
        else
          result = false
        end
      end

      if result
        redirect_to get_bind_backend_shop_account_url(@current_shop, @account, params: {mode: params[:mode]}), notice: "绑定成功"
      else
        flash[:error] = '绑定失败, 请先关注点单通服务号, 发送@消息，并点击返回的消息。'
        redirect_to get_bind_backend_shop_account_url(@current_shop, @account, params: {mode: params[:mode]})
      end
    end

    def unbind
      @account.update_column(:user_id, nil)
      redirect_to get_bind_backend_shop_account_url(@current_shop, @account, params: {mode: params[:mode]}), notice: "解绑成功"
    end

    def edit
    end

    def edit_password
    end

    def update_password
      if @account.update(account_params)
        redirect_to [:edit_password, :backend, @current_shop, @account], notice: '修改密码成功'
      else
        render :edit_password
      end
    end

    def update
      if @account.update(account_params)
        @account.touch
        redirect_to [:backend, @current_shop, @account], notice: "#{t('activerecord.models.ddt/account')} 更新成功."
      else
        render :edit
      end
    end

    def unlock
      unless @account.is_admin? && @account.id == current_account.id
        @account.unlock_access!
      end
      redirect_to :back, notice: '解锁成功'
    end

    def destroy
      if @account.id == current_account.id
        redirect_to backend_shop_accounts_url(@current_shop), notice: "删除失败，错误原因不能删除自己"
      end
      if @account.destroy
        redirect_to backend_shop_accounts_url(@current_shop), notice: "#{t('activerecord.models.ddt/account')} 删除成功."
      else
        redirect_to backend_shop_accounts_url(@current_shop), notice: "删除失败，错误原因 #{@account.errors.full_messages.join(',')}."
      end
    end

    def show
      if @account.is_cook?
        @branches_config_ok = @account.manage_branches.count > 0
        @products_config_ok = @account.products.count > 0
      else
        @branches_config_ok = true
        @products_config_ok = true
      end
    end

    private
    def set_account
      @account = @collection.find(params[:id])
    end

    def set_account_collection
      @collection = if @current_branch.present?
        @current_branch.managers
      else
        @current_shop.accounts
      end
      if current_account.is_worker?
        @collection = @collection.manage_by_worker(current_account)
      else
        @collection
      end
    end

    def account_params
        params.require(:account).permit(:phone, :name, :password, :password_confirmation, :login_id, :email, :notification_email, :receive_email, :user_id, :role_ids_string, :manage_branch_ids_string, :ban_login_app_when_no_open)
    end
  end
end
