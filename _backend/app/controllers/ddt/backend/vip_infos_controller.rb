module Ddt
  class Backend::VipInfosController < Backend::BaseController
    check_permission :shop, :user, base_permission_actions.merge({
      [:applying, :get_bindable] => :show,
      [:agree, :reject, :edit_pay_password, :update_pay_password, :remind_bind] => :update,
      destroy_all: :destroy,
      [:import_vip_infos, :import_failed, :error_vip_infos] => :create,
    })
    before_action :set_vip_info, only: [:show, :edit, :update, :destroy, :edit_pay_password, :update_pay_password, :agree, :reject]

    def index
      @vip_levels = @current_shop.vip_levels
      respond_to do |format|
        format.html {
          @q = @current_shop.vip_infos.ransack(params[:q])
          @vip_infos = @q.result(distinct: true).paginate(page: params[:page])
        }
        format.json {
          @q = @current_shop.vip_infos.ransack(params[:q])
          @vip_infos = @q.result(distinct: true).paginate(page: params[:page])
          render :json => @vip_infos.flatten.map(&:select_json)
        }
        format.csv { send_data @current_shop.vip_infos.not_default_level.to_csv }
        format.xls { send_data @current_shop.vip_infos.not_default_level.to_xls, filename: 'vip_info.xls', type: "application/vnd.ms-excel"}
      end
    end

    def applying
      @q = @current_shop.vip_infos.applying.ransack(params[:q])
      @vip_infos = @q.result.paginate(page: params[:page])
    end

    def agree
      if @vip_info.agree_apply_vip
        redirect_to [:applying, :backend, @current_shop, :vip_infos], notice: '已同意该会员申请'
      else
        redirect_to [:applying, :backend, @current_shop, :vip_infos], alert: "#{@vip_info.errors.full_messages.join(' ')}"
      end
    end

    def reject
      @vip_info.reject_apply_vip
      redirect_to [:applying, :backend, @current_shop, :vip_infos], notice: '拒绝成功'
    end

    def show
      @base_user = @vip_info.base_user
      if @base_user.present?
        render layout: 'ddt/layouts/backend/user'
      else
        render :show
      end
    end

    def new
      @vip_info = @current_shop.vip_infos.build
    end

    def edit
      @base_user = @vip_info.base_user
      if @base_user.present?
        render layout: 'ddt/layouts/backend/user'
      else
        render :edit
      end
    end

    def create
      @vip_info = @current_shop.vip_infos.build(vip_info_params)

      if @vip_info.save
        redirect_to [:backend, @current_shop, @vip_info], notice: "#{t('activerecord.models.ddt/vip_info')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @vip_info.update(vip_info_params)
        redirect_to [:backend, @current_shop, @vip_info], notice: "#{t('activerecord.models.ddt/vip_info')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      @vip_info.destroy
      respond_to do |format|
        format.js
      end
    end

    def destroy_all
      @current_shop.vip_infos.where('base_users_count = 0').destroy_all
      redirect_to backend_shop_vip_infos_url(@current_shop), notice: "#{t('activerecord.models.ddt/vip_info')} 删除成功."
    end

    def edit_pay_password
      @base_user = @vip_info.base_user
      render layout: 'ddt/layouts/backend/user'
    end

    def update_pay_password
      if @vip_info.update(vip_info_params)
        redirect_to [:backend, @current_shop, @vip_info], notice: "#{t('activerecord.models.ddt/vip_info')} 更新支付密码成功."
      else
        render :edit_pay_password
      end
    end

    def import_vip_infos
      if params[:file].present?
        begin
          result = VipInfo.update_and_create_from_file(@current_shop, params[:file])
          if result
            flash[:notice] = "导入成功"
          else
            flash[:error] = "导入失败，请下载错误提示文件修改后再上传。"
            redirect_to import_failed_backend_shop_vip_infos_path(@current_shop)
            return
          end
        rescue => e
          flash[:error] = e.message
        end
      else
        flash[:error] = "请选择文件后再上传!"
      end
      redirect_to vip_users_backend_shop_base_users_path(@current_shop)
    end

    def import_failed
      last_error = @current_shop.last_import_vip_info_error
      redirect_to vip_users_backend_shop_base_users_path(@current_shop) if last_error.blank?
    end

    def error_vip_infos
      last_error = @current_shop.last_import_vip_info_error
      if last_error.present?
        respond_to do |format|
          format.csv { send_data last_error }
        end
      else
        redirect_to vip_users_backend_shop_base_users_path(@current_shop)
      end
    end

    def get_bindable
      @q = @current_shop.vip_infos.not_default_level.not_bind_wechat_user.ransack(params[:q])
      @vip_infos = @q.result(distinct: true).paginate(page: params[:page])
    end

    def remind_bind
      if vip_info_params.blank?
        @vip_infos = @current_shop.vip_infos.not_default_level.not_bind_wechat_user
      else
        @vip_infos = @current_shop.vip_infos.where(id: vip_info_params[:vip_info_ids])
      end
      @errors = []
      @vip_infos.each do |vip_info|
        message = Ddt::ShortMessage.wrap_custom_message_to_send(@current_shop, vip_info.phone, "尊敬的#{vip_info.name}， 即日起，您可以在微信上绑定您的#{@current_shop.name}会员身份，无需携带会员卡片也可享受会员服务。")
        unless message.save
          @errors << "#{vip_info.name} #{message.errors.full_messages}"
        end
      end
      respond_to do |format|
        format.js {render :remind_bind}
      end
    end

    private
      def set_vip_info
        @vip_info = @current_shop.vip_infos.find(params[:id])
      end

      def vip_info_params
        if["remind_bind"].include? action_name
          params.require(:vip_info).permit(vip_info_ids: []) if params[:vip_info]
        else
          params.require(:vip_info).permit(:phone, :name, :vip_level_id, :pay_password, :vip_no, :is_verified,
             :sex, :id_number, :birthday, :address, :email, :avatar, :note)
        end
      end
  end
end
