module Ddt
  class Backend::WechatAccountsController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage
    before_action :set_wechat_account, only: [:show, :edit, :update, :destroy, :upload_server_auth_file]
    layout lambda { params[:layout_name]||'ddt/layouts/backend' }

    def index
      @wechat_accounts = @current_shop.wechat_accounts.paginate(page: params[:page])
    end

    def show
      render layout: 'ddt/layouts/backend/wechat_account'
    end

    def new
      @wechat_account = @current_shop.wechat_accounts.build
    end

    def wechat_users
      if @errors.present?
        render :json => [{error: @errors.join(",")}]
        return
      end
      if @current_shop.is_custom_system_weixin_notification
        @wechat_account = @current_shop.primary_wechat_account
        @q = @wechat_account.shop.users.includes(:wechat_users, :unique_user).where(ddt_wechat_users: { gonghao_open_id: @wechat_account.gonghao_open_id }).ransack(params[:q].try(:merge, m: 'or'))
      else
        @wechat_account = Ddt::WechatAccount.system_wechat_account
        @q = @wechat_account.shop.users.includes(:unique_user).ransack(params[:q].try(:merge, m: 'or'))
      end
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

    def edit
      render layout: 'ddt/layouts/backend/wechat_account'
    end

    def auto_config
      @wechat = Ddt::GhConfig.new(wechat_account_params, @current_shop, common_shop_gh_config_api_url(@current_shop))
      result = @wechat.auto_config
      unless result
        flash[:inp_err] = t 'gh autoconfig fail'
        if wechat_account_params[:id].present?
          @wechat_account = @current_shop.wechat_accounts.find(wechat_account_params[:id])
          render :edit
        else
          @wechat_account = @current_shop.wechat_accounts.build
          render :new
        end
      else
        flash[:success] = t 'gh autoconfig success'
        @wechat_account = result
        render :show
      end
    end

    def create
      @wechat_account = @current_shop.wechat_accounts.build(wechat_account_params)

      if @wechat_account.save
        redirect_to [:backend, @current_shop, @wechat_account], notice: "#{t('activerecord.models.ddt/wechat_account')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @wechat_account.update(wechat_account_params)
        redirect_to [:backend, @current_shop, @wechat_account], notice: "#{t('activerecord.models.ddt/wechat_account')} 更新成功."
      else
        render :edit, layout: 'ddt/layouts/backend/wechat_account'
      end
    end

    def destroy
      @wechat_account.destroy
      redirect_to backend_shop_wechat_accounts_url(@current_shop), notice: "#{t('activerecord.models.ddt/wechat_account')} 删除成功."
    end

    def component_auth
      redirect_to WechatComponent.instance.get_component_oauth_url(@current_shop.id)
    end

    def upload_server_auth_file
      if params[:file].present?
        @wechat_account.server_auth_file = params[:file]
        if @wechat_account.save
          redirect_to [:backend, @current_shop, :wechat_accounts], notice: '上传成功'
        else
          redirect_to [:backend, @current_shop, :wechat_accounts], notice: '上传失败'
        end
      else
        redirect_to [:backend, @current_shop, :wechat_accounts], notice: '上传文件不存在'
      end
    end

    private
      def set_wechat_account
        @wechat_account = @current_shop.wechat_accounts.find(params[:id])
      end

      def wechat_account_params
        params.require(:wechat_account).permit(:id, :token, :app_id, :app_secret, :gonghao_open_id,
          :public_account_name, :gonghao_type, :be_verified, :is_primary, :username, :password,
          :weixin_hao, :default_branch_id)
      end
  end
end
