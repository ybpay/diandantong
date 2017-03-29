module Ddt
  class Backend::BranchGroupsController < Backend::BaseController
    check_permission :shop, :branch_group
    before_action :set_branch_group, only: [:show, :edit, :update, :destroy]

    def index
      @q = @current_shop.branch_groups.ransack(params[:q])
      @branch_groups = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.html {render :index}
        format.json {render json: @branch_groups.map(&:select_json)}
      end
    end

    def show
    end

    def new
      @branch_group = @current_shop.branch_groups.build
    end

    def edit
    end

    def create
      @branch_group = @current_shop.branch_groups.build(branch_group_params)

      if @branch_group.save
        redirect_to [:backend, @current_shop, @branch_group], notice: "#{t('activerecord.models.ddt/branch_group')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @branch_group.update(branch_group_params)
        redirect_to [:backend, @current_shop, @branch_group], notice: "#{t('activerecord.models.ddt/branch_group')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @branch_group.destroy
        redirect_to backend_shop_branch_groups_url(@current_shop), notice: "#{t('activerecord.models.ddt/branch_group')} 删除成功."
      else
        flash[:error] = @branch_group.errors.full_messages.join(", ")
        redirect_to backend_shop_branch_groups_url(@current_shop)
      end
    end

    private
    def set_branch_group
      @branch_group = @current_shop.branch_groups.find(params[:id])
    end

    def branch_group_params
      params.require(:branch_group).permit(
        :name, :branch_ids_string
      )
    end
  end
end
