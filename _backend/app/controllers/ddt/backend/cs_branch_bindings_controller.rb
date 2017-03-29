module Ddt
  class Backend::CsBranchBindingsController < Backend::BaseController
    check_permission :branch, :cs_branch_binding, { show: :show, [:edit, :update] => :update}
    before_action :set_cs_branch_binding, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/branch'

    def show
      @cs_online_logs = Ddt::CsOnlineLog.where(
        branch_id: @current_branch.id
      ).paginate(page: params[:page], per_page: 20)
    end

    def edit
    end

    def update
      if @cs_branch_binding.update(cs_branch_binding_params)
        redirect_to backend_shop_branch_cs_branch_binding_path(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/cs_branch_binding')} 更新成功."
      else
        render :edit
      end
    end

    def create
      @cs_branch_binding = @current_branch.create_cs_branch_binding
      redirect_to backend_shop_branch_cs_branch_binding_url(@current_shop, @current_branch)
    end

    private
      def set_cs_branch_binding
        @cs_branch_binding = @current_branch.cs_branch_binding
        if !@cs_branch_binding.present? && !current_account.is_admin?
          flash[:error] = '只有管理员可以开启CS模式'
          redirect_to backend_shop_branch_url(@current_shop, @current_branch)
        end
      end

      def cs_branch_binding_params
        if current_account.is_admin?
          params.require(:cs_branch_binding).permit(:force_online, :http_proxy_url)
        else
          params.require(:cs_branch_binding).permit(:http_proxy_url)
        end
      end
  end
end
