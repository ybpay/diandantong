module Ddt
  class Backend::Product::ProductsController < Backend::BaseController
    check_permission :branch, :product, base_permission_actions.merge({
       :search => :show,
       [:import_products, :import_failed, :error_products, :batch_copy, :copy] => :create,
       :batch_remove => :destroy,
       [:batch_on_shelf, :batch_off_shelf, :create_qrcode] => :update,
       [:batch_estimate_clear, :batch_estimate_full] => :estimate_clear,
      })
    before_action :set_product, only: [:show, :edit, :update, :destroy, :create_qrcode, :change_position]
    before_action :set_branches, only: [:batch_copy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/product' }
    def index
      params[:q] = {s: "created_at desc"} if params[:q].blank?
      @q = @current_branch.products.includes(:variants_including_master).ransack(params[:q])
      @products = @q.result.distinct.paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {render :json => @products.map(&:variants_including_master).flatten.map(&:select_json) }
        format.csv { send_data @current_branch.products.to_csv }
        format.xls { send_data @current_branch.products.to_xls, filename: 'products.xls', type: "application/vnd.ms-excel"}
      end
    end

    def search
      @q = @current_branch.products.ransack(params[:q])
      @products = @q.result.distinct.paginate(page: params[:page])
      respond_to do |format|
        format.json {
          render :json => @products.map(&:select_json)
        }
      end
    end

    def import_products
      if params[:file].present?
        begin
          result = Product.update_and_create_from_file(@current_branch, params[:file])
          if result
            flash[:notice] = "导入成功"
          else
            flash[:error] = "导入失败，请下载错误提示文件修改后再上传。"
            redirect_to import_failed_backend_shop_branch_products_path(@current_shop, @current_branch)
            return
          end
        rescue => e
          flash[:error] = e.message
        end
      else
        flash[:error] = "请选择文件后再上传!"
      end
      redirect_to backend_shop_branch_products_path(@current_shop, @current_branch)
    end

    def import_failed
      last_error = @current_branch.last_import_product_error
      if last_error.nil?
        redirect_to backend_shop_branch_products_path(@current_shop, @current_branch)
      end
    end

    def error_products
      last_error = @current_branch.last_import_product_error
      if last_error.present?
        respond_to do |format|
          format.csv { send_data last_error.error_csv }
        end
      else
        redirect_to backend_shop_branch_products_path(@current_shop, @current_branch)
      end
    end

    def batch_remove
      if product_params[:product_ids].nil? or product_params[:product_ids].empty?
        flash[:error] = "您必须选择要删除的产品!"
      else
        products = @current_branch.products.where(id: product_params[:product_ids])
        product_names = products.map(&:name).join(',')
        products.destroy_all
        flash[:success] = "恭喜您，成功删除如下产品:#{product_names}."
      end
      redirect_to backend_shop_branch_products_path(@current_shop, @current_branch,page: params[:page])
    end

    # 批量上架
    def batch_on_shelf
      ids = product_params[:product_ids]
      if ids.present?
        @current_branch.products.set_on_shelf ids
        product_names = @current_branch.products.where(id: ids).map(&:name).join(",")
        flash[:success] = "恭喜您，成功上架如下产品:#{product_names}"
      else
        flash[:error] = "您必须选择要上架的产品!"
      end
      redirect_to backend_shop_branch_products_path(@current_shop, @current_branch,page: params[:page])
    end

    # 批量下架
    def batch_off_shelf
      ids = product_params[:product_ids]
      if ids.present?
        @current_branch.products.set_off_shelf ids
        product_names = @current_branch.products.where(id: ids).map(&:name).join(",")
        flash[:success] = "恭喜您，成功下架如下产品:#{product_names}"
      else
        flash[:error] = "您必须选择要下架的产品!"
      end
      redirect_to backend_shop_branch_products_path(@current_shop, @current_branch,page: params[:page])
    end
    #批量估清
    def batch_estimate_clear
      ids = product_params[:product_ids]
      if ids.present?
        @current_branch.products.set_estimate_clear ids
        product_names = @current_branch.products.where(id: ids).map(&:name).join(",")
        flash[:success] = "成功估清以下产品:#{product_names}"
      else
        flash[:error] = "您必须要选择估清的产品"
      end
      redirect_to backend_shop_branch_products_path(@current_shop, @current_branch,page: params[:page])
    end
    #批量去除估清
    def batch_estimate_full
      ids = product_params[:product_ids]
      if ids.present?
        @current_branch.products.set_estimate_full ids
        product_names = @current_branch.products.where(id: ids).map(&:name).join(",")
        flash[:success] = "成功估清以下产品:#{product_names}"
      else
        flash[:error] = "您必须要选择估清的产品"
      end
      redirect_to backend_shop_branch_products_path(@current_shop, @current_branch,page: params[:page])
    end

    # 批量复制
    def batch_copy
      if @branches.present?
        @message = Ddt::ProductCopy.copy_products_to_branchs(products_to_copy, @branches, params[:replace_same_product])
        @message = "复制完成！" + @message
      else
        @message = "请先选择目标门店"
      end
    end

    def copy
      if params[:product].present?
        @ids = product_params[:product_ids].join(",")
      end
    end

    def show

    end

    def new
      @product = @current_branch.products.build(availabled_at: DateTime.now)
    end

    def create
      @product = @current_branch.products.build(product_params)
      if @product.save
        redirect_to [:backend, @current_shop, @current_branch, @product], notice: "#{t('activerecord.models.ddt/product')} 创建成功."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        @product.touch
        redirect_to [:backend, @current_shop, @current_branch, :products], notice: "#{t('activerecord.models.ddt/product')} 修改成功."
      else
        render :edit
      end
    end

    def destroy
      @product.destroy
      redirect_to [:backend, @current_shop, @current_branch, :products], notice: "#{t('activerecord.models.ddt/product')} 删除成功."
    end


    def create_qrcode
      @product.create_qr_code
      redirect_to [:backend, @current_shop, @current_branch, @product]
    end

    def change_position
      # @product.change_position(params[:position])
      @product.update_attribute(:position, params[:position])
      render 'reset'
    end

    private
    def product_params
      if ['batch_remove', 'batch_on_shelf', 'batch_off_shelf', 'batch_estimate_clear' ,'batch_estimate_full', 'copy'].include? action_name
        params.require(:product).permit(product_ids: [])
      else
        params.require(:product).permit(:name, :description, :name_abbr, :unit_name, :availabled_at,
                                       :support_delivery, :support_reservation, :support_eat_in_hall, :sale_on_monday, :sale_on_tuesday, :sale_on_wednesday, :sale_on_thursday, :sale_on_friday, :sale_on_saturday, :sale_on_sunday,
                                       :price, :vip_price, :sku, :position, :stock_quantity, :sale_quantity, :by_weight, :default_weight,
                                       :option_type_ids_string, :item_note_ids_string, :category_ids_string, :tag_names, :start_time, :end_time, :enable_discount, :min_quantity_for_order, :show_note_in_weixin, :show_on_wechat, :on_shelf, :enable_change_price, :nfc_code)
      end
    end

    def set_product
      @product = @current_branch.products.find(params[:id])
    end

    def products_to_copy
      if params[:ids].present?
        products = @current_branch.products.where(id: params[:ids].split(","))
      else
        products = @current_branch.products
      end
    end

    def set_branches
      @branches = []
      if params[:branch_ids].present?
        @branches += @current_shop.branches.where(id: params[:branch_ids].split(","))
      end
      if params[:branch_group_ids].present?
        @branches += @current_branch.branches_in_group(group_ids: params[:branch_group_ids], same_group: false)
      end
      @branches = @branches.uniq
    end

  end
end
