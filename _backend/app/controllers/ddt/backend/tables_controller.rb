module Ddt
  class Backend::TablesController < Backend::BaseController
    check_permission :branch, :table, base_permission_actions.merge({
      [:enable_qr_code, :disable_qr_code, :regenerate_qr_code] => :update,
      [:get_order, :export_all, :get_export_list] => :show,
      [:get_batch_create, :post_batch_create] => :create,
    })
    include Backend::PaginateExportAll
    include Backend::TempAttribute
    before_action :set_table, only: [:show, :edit, :update, :destroy, :update_state, :get_order, :enable_qr_code, :disable_qr_code, :regenerate_qr_code]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/branch' }

    def index
      search
      @tables = @q.result.paginate(page: params[:page], per_page: params[:per_page])
      @paginate=true
      
      respond_to do |format|
        format.html
        format.json {render json: @tables.map(&:select_json)}
      end
    end

    def show
    end

    
    def enable_qr_code
      if @table.present?
        @table.enable_qr_code
      end
      redirect_to backend_shop_branch_tables_path(@current_shop, @current_branch, style: 'qrcode')
    end

    def disable_qr_code
      if @table.present?
        @table.disable_qr_code
      end
      redirect_to backend_shop_branch_tables_path(@current_shop, @current_branch, style: 'qrcode')
    end

    def regenerate_qr_code
      if @table.present?
        @table.regenerate_qr_code
      end
      redirect_to backend_shop_branch_tables_path(@current_shop, @current_branch, style: 'qrcode')
    end

    def new
      @table = @current_branch.tables.build(table_zone_id: params[:table_zone_id])
    end

    def edit
    end

    def create
      @table = @current_branch.tables.build(table_params)

      if @table.save
        redirect_to [:backend, @current_shop, @current_branch, @table], notice: "#{t('activerecord.models.ddt/table')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @table.update(table_params)
        redirect_to [:backend, @current_shop, @current_branch, @table], notice: "#{t('activerecord.models.ddt/table')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @table.destroy
        redirect_to :back, notice: "#{t('activerecord.models.ddt/table')} 删除成功."
      else
        flash[:error] = @table.errors.full_messages.join('<br/>')
        redirect_to :back
      end
    end

    def get_order
      @order = @table.current_order
      respond_to do |format|
        format.js
      end
    end

    def export_all
      search
      @tables = @q.result.paginate(page: params[:page], per_page: params[:per_page])
      respond_to do |format|
        if @tables.size > 0
          suffix = params[:page].present? ? "_part_#{params[:page]}" : ""
          if %W[h v original].include? params[:version]
            version = params[:version].to_sym
            tmp_zip_file = Ddt::QrCodeScenesExport.export_table_sticker(@tables.map(&:qr_code_scene), @current_branch, version)
            format.zip { send_file tmp_zip_file.path, :filename => "export_qr_codes#{suffix}.zip" }
          else
            format.zip { send_data "参数错误", :filename => "params_error.txt"}
          end
        else
          format.zip { send_data "您还没有设置桌台", :filename => "table_notset.txt"}
        end
      end
    end

    def get_batch_create
      @batch_create_table_form = Ddt::BatchCreateTableForm.new
    end

    def post_batch_create
      params.require(:batch_create_table_form).permit(:start_name, :count, :table_zone_id, :capacity)
      @batch_create_table_form = Ddt::BatchCreateTableForm.new(params[:batch_create_table_form].merge({branch: @current_branch}))
      if @batch_create_table_form.valid?
        @batch_create_table_form.perform
        redirect_to [:backend, @current_shop, @current_branch, :tables], notice: "批量创建成功."
      else
        render :get_batch_create
      end
    end

    private
      def search
        @q = @current_branch.tables.includes(:qr_code_scene).ransack(params[:q])
      end

      def set_export_all_path
        @export_all_path = export_all_backend_shop_branch_tables_path(@current_shop, @current_branch, format: "zip", params: params)
      end

      def set_table
        @table = @current_branch.tables.find(params[:id])
      end

      def table_params
        if 'bind' == action_name
          params.require(:table).permit(:target_table_id)
        else
          params.require(:table).permit(:name, :table_zone_id, :capacity, :current_order_id, :position)
        end
      end

  end
end
