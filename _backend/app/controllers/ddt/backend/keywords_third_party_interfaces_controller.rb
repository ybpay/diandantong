module Ddt
  class Backend::KeywordsThirdPartyInterfacesController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage
    before_action :set_wechat_account
    before_action :set_keywords_third_party_interface, only: [:show, :edit, :update, :destroy]

    def index
      @keywords_third_party_interfaces = @wechat_account.keywords_third_party_interfaces
    end

    def new
      @keywords_third_party_interface = @wechat_account.keywords_third_party_interfaces.build
    end

    def show
    end

    def edit
    end

    def create
      @keywords_third_party_interface = @wechat_account.keywords_third_party_interfaces.build(keywords_third_party_interface_params)
      if @keywords_third_party_interface.save
        redirect_to [:backend, @current_shop, @wechat_account, :keywords_third_party_interfaces]
      else
        render :new
      end
    end

    def update
      if @keywords_third_party_interface.update(keywords_third_party_interface_params)
        redirect_to [:backend, @current_shop, @wechat_account, :keywords_third_party_interfaces]
      else
        render :edit
      end
    end

    def destroy
      @keywords_third_party_interface.destroy
      redirect_to [:backend, @current_shop, @wechat_account, :keywords_third_party_interfaces]
    end

    private
    def set_keywords_third_party_interface
      @keywords_third_party_interface = @wechat_account.keywords_third_party_interfaces.find(params[:id])
    end

    def set_wechat_account
      @wechat_account = @current_shop.wechat_accounts.find(params[:wechat_account_id]) rescue nil
    end

    def keywords_third_party_interface_params
      params.require(:keywords_third_party_interface).permit(:keywords, :api, :match_type, :token, :opened)
    end
  end
end