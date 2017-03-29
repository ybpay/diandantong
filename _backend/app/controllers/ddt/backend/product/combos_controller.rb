module Ddt
  class Backend::Product::CombosController < Backend::BaseController
    check_permission :branch, :combo, base_permission_actions.merge({
        [:get_batch_copy, :post_batch_copy] => :create,
        [:batch_on_shelf, :batch_off_shelf] => :update,
      })
    before_action :set_combo, only: [:show, :edit, :update, :destroy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/combo' }
    def index
      @q = @current_branch.combos.ransack(params[:q])
      @combos = @q.result.distinct.paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {
          render :json => @combos.map(&:select_json)
        }
      end
    end

    def show

    end

    def new
      @combo = @current_branch.combos.new
    end

    def create
      @combo = @current_branch.combos.build(combo_params)
      if @combo.save
        redirect_to [:backend, @current_shop, @current_branch, :combos], notice: "#{t('activerecord.models.ddt/combo')} 创建成功."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @combo.update(combo_params)
        redirect_to [:backend, @current_shop, @current_branch, :combos], notice: "#{t('activerecord.models.ddt/combo')} 修改成功."
      else
        render :edit
      end
    end

    def destroy
      @combo.destroy
      redirect_to [:backend, @current_shop, @current_branch, :combos], notice: "#{t('activerecord.models.ddt/combo')} 删除成功."
    end

    def change_position
      @combo.change_position(params[:position])
      redirect_to [:backend, @current_shop, @current_branch, :combos]
    end

    def get_batch_copy
      if params[:combo].present?
        @ids = combo_params[:combo_ids].join(",")
      end
    end

    def post_batch_copy
      @branches = managed_branches.where(id: params[:branch_ids].split(",")) if params[:branch_ids].present?
      if @branches.present?
        @combos = combos_to_copy
        @message = Ddt::ProductCopy.copy_combos_to_branches(@combos, @branches)
        render :post_batch_copy
      else
        @message = "请先选择目标门店"
        render :get_batch_copy
      end
    end

    # 批量上架
    def batch_on_shelf
      ids = combo_params[:combo_ids]
      if ids.present?
        @current_branch.combos.set_on_shelf ids
        combo_names = @current_branch.combos.where(id: ids).map(&:name).join(",")
        flash[:success] = "恭喜您，成功上架如下套餐:#{combo_names}"
      else
        flash[:error] = "您必须选择要上架的套餐!"
      end
      redirect_to backend_shop_branch_combos_path(@current_shop, @current_branch)
    end

    # 批量下架
    def batch_off_shelf
      ids = combo_params[:combo_ids]
      if ids.present?
        @current_branch.combos.set_off_shelf ids
        combo_names = @current_branch.combos.where(id: ids).map(&:name).join(",")
        flash[:success] = "恭喜您，成功下架如下套餐:#{combo_names}"
      else
        flash[:error] = "您必须选择要下架的套餐!"
      end
      redirect_to backend_shop_branch_combos_path(@current_shop, @current_branch)
    end

    private

    def combos_to_copy
      if params[:ids].present?
        @current_branch.combos.where(id: params[:ids].split(","))
      else
        @current_branch.combos
      end
    end

    def combo_params
      if ['get_batch_copy', 'batch_on_shelf', 'batch_off_shelf'].include? action_name
        params.require(:combo).permit(combo_ids: [])
      else
        params.require(:combo).permit(:name, :description, :unit_name, :availabled_at, :end_at, :stock_quantity, :on_shelf,
                                     :support_delivery, :support_reservation, :support_eat_in_hall, :sale_on_monday, :sale_on_tuesday, :sale_on_wednesday, :sale_on_thursday, :sale_on_friday, :sale_on_saturday, :sale_on_sunday,
                                     :sku, :start_time, :end_time, :enable_discount, :show_on_wechat, :enable_change_price)
      end

    end

    def set_combo
      @combo = @current_branch.combos.find(params[:id])
    end
  end
end
