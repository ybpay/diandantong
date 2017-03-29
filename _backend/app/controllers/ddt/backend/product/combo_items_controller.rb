module Ddt
  class Backend::Product::ComboItemsController < Backend::BaseController
    check_permission :branch, :combo, {[:index, :show] => :show, [:new, :create, :edit, :update, :destroy, :change_position] => :update}
    before_action :set_combo
    before_action :set_combo_item, only: [:show, :edit, :update, :destroy, :change_position]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/combo' }
    def index
      @combo_items = @combo.combo_items
    end

    def show

    end

    def new
      @combo_item = @combo.combo_items.new
    end

    def create
      @combo_item = @combo.combo_items.build({combo_id: @combo.id}.merge append_price_strategy(combo_item_params))
      if @combo_item.save
        redirect_to [:backend, @current_shop, @current_branch, @combo, :combo_items], notice: '创建成功'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @combo_item.update( append_price_strategy(combo_item_params))
        @combo_item.touch
        redirect_to [:backend, @current_shop, @current_branch, @combo, :combo_items], notice: '更新成功'
      else
        render :edit
      end
    end

    def destroy
      @combo_item.destroy
      render :reset
    end

    def change_position
      @combo_item.change_position(params[:position])
      render :reset
    end

    private
    def combo_item_params
      params.require(:combo_item).permit(
        :name, :select_count, :is_necessary, :price_strategy, :price, :vip_price,
        combo_items_variants_attributes: [:id, :variant_id, :price, :vip_price, :_destroy]
        )
    end

    def append_price_strategy(params)
      if params[:combo_items_variants_attributes].present?
        params[:combo_items_variants_attributes].each do |civ_attr|
          civ_attr[1][:price_strategy] = params[:price_strategy]
        end
      end
      params
    end

    def set_combo
      @combo = @current_branch.combos.find(params[:combo_id])
    end

    def set_combo_item
      @combo_item = @combo.combo_items.find(params[:id])
    end
  end
end
