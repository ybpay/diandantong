module Ddt
  class Backend::TableColorsController < Backend::BaseController
    check_permission :shop, :custom_setting, {show: :show, [:edit, :update] => :update}
    before_action :set_table_color, only: [:show, :edit, :update]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/shop' }
    respond_to :html

    def show
      respond_with(@table_color)
    end

    def edit
    end

    def update
      if @table_color.update(table_color_params)
        redirect_to [:backend, @current_shop, :table_color], notice: '更新成功'
      else
        render action: 'edit'
      end
    end

    private
      def set_table_color
        @table_color = @current_shop.table_color
      end

      def table_color_params
        params.require(:table_color).permit(:idle_color, :opened_color, :ordered_color, :check_outing_color, :paid_color, :active_color)
      end
  end
end