module Ddt
  class Backend::ShopsController < Backend::BaseController
    before_action  :check_admin_auth, :only => [:index]
    check_permission :shop, :shop, { [:welcome, :show, :copy_link] => :show, :dashboard => :dashboard, [:module_index, :export_accounts, :show_search_word, :edit_search_word, :update_search_word, :edit, :update, :config_guide, :update_sale_employee] => :update}, :except =>[:index, :crm]
    before_action :set_shop, except: [:index, :export_accounts, :config_guide]

    layout lambda { params[:layout_name]||'ddt/layouts/backend/shop' }, except: [:dashboard, :index, :config_guide, :crm]

    def index
      @q = Ddt::Shop.includes(:accounts).all.ransack(params[:q])
      @shops = @q.result(distinct: true).paginate(page: params[:page])
      respond_to do |format|
        format.json {
          render :json => @shops.map(&:select_json)
        }
        format.html {render layout: 'ddt/layouts/backend'}
      end

    end

    def crm
      @account_info = {
        id: current_account.id,
        name: current_account.name,
        email: current_account.email,
        phone: current_account.phone,
        shop_id: current_account.shop_id,
        roles: current_account.roles.map(&:name),
        shop_name: @current_shop.name
      }
      render layout: "ddt/layouts/backend_crm"
    end

    def welcome
      render layout: 'ddt/layouts/backend'
    end

    def home
      if params[:menu_group].present? && Ddt::Backend::Sidebar::MENU_GROUPS.include?(params[:menu_group].to_sym)
        session[:menu_group] = params[:menu_group]
      end
    end

    def show
    end

    def export_accounts
      start_time = Time.parse(params[:shop_create_time][:start])
      end_time = Time.parse(params[:shop_create_time][:end])
      is_paid_shop = params[:shop_create_time][:is_paid_shop].to_i

      if is_paid_shop > 0
        shops = Ddt::Shop.includes(:shop_recharge_records).where(:created_at=>start_time..end_time, :agent_no=>[nil, ""]).where("ddt_shop_recharge_records.price > 0")
      else
        shops = Ddt::Shop.where(:created_at=>start_time..end_time, :agent_no=>[nil, ""])
      end
      accounts = []
      shops.each do |shop|
        shop.accounts.each do |account|
          if account.is_boss?
            accounts << account
          end
        end
      end
      respond_to do |format|
        format.csv { send_data Ddt::Account.to_csv(accounts,col_sep: ","), :filename => "accounts_#{start_time}_#{end_time}.csv" }
      end
    end

    def dashboard
      @page_bg_class = 'white-bg'
      # 1月1号后可删除
      @result = []
      @variants = []

      unless @current_account.is_admin?
        sql = "select branch_id, sku as counter_of_id from ddt_variants where branch_id in (#{current_account.managed_branches.map(&:id).join(',')}) and is_master = 0 and deleted_at is NULL group by sku, branch_id having count(id) > 1"
        @result = ActiveRecord::Migration.connection.execute(sql).to_a
        condition = @result[0..9].map{|branch_id_with_sku| "(branch_id = #{branch_id_with_sku[0]} and sku = '#{branch_id_with_sku[1]}')"}.join(" or ")
        @variants = Ddt::Variant.where(condition) if condition.present?
      end

      respond_to do |format|
        format.html { render layout: 'ddt/layouts/backend_empty' }
      end
    end

    def copy_link
      render layout: "/ddt/layouts/backend"
    end

    def module_index
      render layout: "/ddt/layouts/backend"
    end

    def show_search_word
    end

    def edit_search_word
    end

    def update_search_word
      if @shop.update(shop_params)
        redirect_to [:show_search_word, :backend, @shop], notice: "#{t('activerecord.models.ddt/shop')} 更新成功."
      else
        render :edit_search_word
      end
    end

    def edit
    end

    def update
      if @shop.update(shop_params)
        redirect_to [:backend, @shop], notice: "#{t('activerecord.models.ddt/shop')} 更新成功."
      else
        render :edit
      end
    end




    def config_guide
      respond_to do |format|
        format.html { render layout: 'ddt/layouts/backend' }
      end
    end

    def update_sale_employee
      if @current_shop.can_choose_sale_employee? && shop_params[:sale_employee_id]
        @current_shop.sale_employee_id = shop_params[:sale_employee_id]
        @current_shop.save
      end
      redirect_to backend_shop_path(@current_shop)
    end

    def feature_modules
      render json: FeatureModules.select_json
    end

    private
      def set_shop
        @shop = Shop.find(params[:id])
      end

      def check_admin_auth
        raise ErrorNoAuthException.new('非点单通公司管理人员无权进行此操作') unless current_account.is_admin?
      end

      def shop_params
        if current_account.is_admin?
          params.require(:shop).permit(:name, :slug, :is_open, :expiration_time, :telephone, :service_email, :sina_weibo,
            :introduction, :image, :rect_image, :charge_method, :use_custom_brand, :is_ban, :is_suspicious,
            :agent_no, :custom_brand_name, :custom_brand_link, :hide_support_brand,
            :enable_foreign, :foreign_currency_symbol, :foreign_time_zone, :vip_logo,
            :reservation_img, :remove_reservation_img, :reservation_img_cache, :shop_type, :max_branches_limit,
            :order_in_seat_img, :remove_order_in_seat_img, :order_in_seat_img_cache,
            :delivery_img, :remove_delivery_img, :delivery_img_cache, :is_set_as_third_part_url,
            :queue_img, :remove_queue_img, :queue_img_cache, :force_fetch_user_info, :is_hide_signup_link,
            :pay_online_img, :remove_pay_online_img, :pay_online_img_cache, :search_words, :is_custom_system_weixin_notification, :custom_system_weixin_template_id, :is_valid_phone, :custom_domain, :debug, :sale_employee_id, :use_shop_name_for_queue)
        else
          params.require(:shop).permit(:name, :telephone, :city_code, :service_email, :sina_weibo,
            :introduction, :image, :rect_image, :enable_foreign, :foreign_currency_symbol, :foreign_time_zone, :foreign_tax_rate, :vip_logo,
            :reservation_img, :remove_reservation_img, :reservation_img_cache,
            :order_in_seat_img, :remove_order_in_seat_img, :order_in_seat_img_cache,
            :delivery_img, :remove_delivery_img, :delivery_img_cache, :is_set_as_third_part_url,
            :queue_img, :remove_queue_img, :queue_img_cache, :force_fetch_user_info,
            :pay_online_img, :remove_pay_online_img, :pay_online_img_cache, :search_words, :is_valid_phone, :sale_employee_id, :use_shop_name_for_queue)
        end
      end
  end
end
