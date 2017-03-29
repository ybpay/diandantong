module Ddt
  class Backend::User::UsersController < Backend::BaseController
    check_permission :shop, :user, { [:index, :show] => :show, [:edit, :update] => :update}
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @q = @current_shop.users.ransack(params[:q])
      @users = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {
          render :json => @users.flatten.map(&:select_json)
        }
      end
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to [:backend, @current_shop, @user], notice: "#{t('activerecord.models.ddt/user')} 更新成功."
      else
        render :edit
      end
    end

    private
      def set_user
        @user = @current_shop.users.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:name, :phone, :orders_count, :is_blocked, :total_amount,
          :type, :shop_id, :vip_info_id, :last_latitude, :last_longitude,
          :last_location_label, :last_location_time, :unique_user_id)
      end
  end
end
