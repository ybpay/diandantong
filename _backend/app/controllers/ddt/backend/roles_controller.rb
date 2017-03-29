module Ddt
  class Backend::RolesController < Backend::BaseController
    check_permission :shop, :role
    before_action :set_role, only: [:show, :edit, :update, :destroy]
    before_action :check_builtin, only: [:edit, :update, :destroy]

    def index
      @q = @current_shop.roles.ransack(params[:q])
      @roles = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {
          render :json => @roles.map{|role| { id: role.id, name: role.display_name }}
        }
      end
    end

    def new
      @role = @current_shop.roles.custom.build
    end

    def create
      @role = @current_shop.roles.custom.build(role_params)
      if @role.save
        redirect_to [:backend, @current_shop, @role], notice: "#{t('activerecord.models.ddt/role')} 创建成功."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @role.update(role_params)
        redirect_to [:backend, @current_shop, @role], notice: "#{t('activerecord.models.ddt/role')} 更新成功."
      else
        render :edit
      end
    end

    def show
    end

    def destroy
      @role.destroy
      redirect_to backend_shop_roles_url(@current_shop), notice: "#{t('activerecord.models.ddt/role')} 删除成功."
    end

    private
    def role_params
      columns = [:display_name, :description] + Role.permission_methods
      params.require(:role).permit(*columns)
    end

    def set_role
      @role = @current_shop.roles.find(params[:id])
    end

    def check_builtin
      redirect_to [:backend, @current_shop, @role], notice: '对不起，该角色为系统角色，不允许改变' if @role.builtin?
    end
  end
end
