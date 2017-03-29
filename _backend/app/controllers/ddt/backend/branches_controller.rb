module Ddt
  class Backend::BranchesController < Backend::BaseController
    include Backend::TempAttribute
    check_permission :shop, :branch,  {
      [:new, :create] => :create,
      destroy: :destroy,
      [:edit, :update, :change_position] => :update,
      [:get_erase, :erase_data, :rollback_data] => :clear_data
    }, except: [:index, :show]
    before_action :set_branch, only: [:show, :edit, :update, :destroy, :change_position, :get_erase, :erase_data, :rollback_data]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }

    def index
      @q = managed_branches.where(is_abstract: false).ransack(params[:q])
      @branches = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.html{
          render layout: 'ddt/layouts/backend'
        }
        format.json {
          render :json => @current_shop.branches_select_json(@branches, params[:multiple].present? ? @q.result(distinct: true).pluck(:id).join(",") : nil)
        }
      end
    end

    def show

    end

    def new
      @branch = @current_shop.branches.build(expiration_time: 2.years.from_now)
      @branch.service_periods.build
      render layout: 'ddt/layouts/backend'
    end

    def edit
    end

    def create
      @branch = @current_shop.branches.build(branch_params.merge({charge_method: 'charge_by_time'}))

      if @branch.save
        redirect_to [:backend, @current_shop, @branch], notice: "#{t('activerecord.models.ddt/branch')} 创建成功."
      else
        render :new, layout: 'ddt/layouts/backend'
      end
    end

    def update
      if @branch.update(branch_params)
        redirect_to [:backend, @current_shop, @branch], notice: "#{t('activerecord.models.ddt/branch')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      @branch.destroy
      redirect_to backend_shop_branches_url(@current_shop), notice: "#{t('activerecord.models.ddt/branch')} 删除成功."
    end

    def change_position
      @branch.change_position(params[:position])
      render :reset
    end

    def get_erase
      add_temp_attributes @branch, :start_time, :end_time
    end

    def erase_data
      if current_account.is_admin?
        if params[:branch][:start_time].blank? || params[:branch][:end_time].blank?
          redirect_to action: :get_erase, notice: "时间区段不完整"
        else
          start_time = (Time.parse params[:branch][:start_time]).strftime("%F %T")
          end_time = (Time.parse params[:branch][:end_time]).strftime("%F %T")
          Ddt::Eraser.perform_shift_data(@branch.id, start_time, end_time)
          Ddt::OrderService::Api::Order.erase_data(@branch.id, start_time, end_time)
          redirect_to action: :get_erase, notice: "#{start_time} ~ #{end_time} 的数据抹除成功"
        end
      end
    end

    def rollback_data
      if current_account.is_admin?
        if params[:branch][:start_time].blank? || params[:branch][:end_time].blank?
          redirect_to action: :get_erase, notice: "时间区段不完整"
        else
          start_time = (Time.parse params[:branch][:start_time]).strftime("%F %T")
          end_time = (Time.parse params[:branch][:end_time]).strftime("%F %T")
          Ddt::Eraser.rollback_shift_data(@branch.id, start_time, end_time)
          Ddt::OrderService::Api::Order.rollback_erase(@branch.id, start_time, end_time)
          redirect_to action: :get_erase, notice: "#{start_time} ~ #{end_time} 的数据恢复成功"
        end
      end
    end

    private
      def set_branch
        @branch = @current_shop.branches.find(params[:id])
      end

      def branch_params
        if current_account.is_boss? || current_account.is_admin?
          params.require(:branch).permit(:name, :open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday, :open_on_friday, :open_on_saturday, :open_on_sunday, :expiration_time, :notice, :note_placeholder, :phone, :address, :latitude,
            :wechat_no, :qq_no, :support_wifi, :support_parking, :parking_space_count, :support_invoice,
            :longitude, :introduction, :product_list_style, :hasten_minute_since_place, :start_time, :end_time,
            :branch_type_id, :branch_category, :delivery_setting_id, :revervation_setting_id, :eat_in_hall_setting_id, :tag_names,
            :use_delivery_setting, :use_reservation_setting, :use_eat_in_hall_setting, :use_fastfood_setting, :use_queue_setting, :use_pay_online_setting,
            :image, :image_cache, :rect_image, :rect_image_cache, :zone_ids_string, :check_stock, :show_stock_quantity, :show_sale_quantity, :promotion_in_webpos, :enable_tts_local, :enable_user_location_limitation, :moling_type, :moling_precision, :moling_auto,
            :table_sticker_custom_line1, :table_sticker_custom_line2, :auto_publish_comment,
            :service_periods_attributes => [:id, :start_at, :end_at, :_destroy])
        else
          # 过滤 :expiration_time
          params.require(:branch).permit(:open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday, :open_on_friday, :open_on_saturday, :open_on_sunday, :notice, :note_placeholder, :phone, :address, :latitude,
            :wechat_no, :qq_no, :support_wifi, :support_parking, :parking_space_count, :support_invoice,
            :longitude, :introduction, :product_list_style, :hasten_minute_since_place,
            :branch_type_id, :branch_category, :delivery_setting_id, :revervation_setting_id, :eat_in_hall_setting_id, :tag_names,
            :use_delivery_setting, :use_reservation_setting, :use_eat_in_hall_setting, :use_fastfood_setting, :use_queue_setting, :use_pay_online_setting,
            :image, :image_cache, :rect_image, :rect_image_cache, :zone_ids_string, :check_stock, :show_stock_quantity, :show_sale_quantity, :promotion_in_webpos, :enable_user_location_limitation, :moling_type, :moling_precision, :moling_auto,
            :table_sticker_custom_line1, :table_sticker_custom_line2, :auto_publish_comment,
            :service_periods_attributes => [:id, :start_at, :end_at, :_destroy])
        end
      end
  end
end
