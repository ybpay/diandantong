module Ddt
  class Backend::DiscountPlansController < Backend::BaseController
    check_permission :branch, :discount_plan
    before_action :set_discount_plan, only: [:edit, :destroy, :update]
    layout 'ddt/layouts/backend/branch'

    def index
      @q = @current_branch.discount_plans.ransack(params[:q])
      @discount_plans = @q.result.distinct.paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.json {
          render json: @discount_plans.map(&:select_json)
        }
      end
    end

    def new
      @discount_plan = @current_branch.discount_plans.build
      @discount_plan.items.build
    end

    def create
      @discount_plan = @current_branch.discount_plans.build(discount_plan_params)
      if @discount_plan.save
        redirect_to [:backend, @current_shop, @current_branch, :discount_plans]
      else
        render :new
      end
    end

    def edit
    end

    def destroy
      @discount_plan.destroy
      redirect_to [:backend, @current_shop, @current_branch, :discount_plans]
    end

    def update
      if @discount_plan.update(discount_plan_params)
        @discount_plan.touch
        redirect_to [:backend, @current_shop, @current_branch, :discount_plans]
      else
        render :edit
      end
    end

    private

    def set_discount_plan
      @discount_plan = @current_branch.discount_plans.find(params[:id])
    end

    def discount_plan_params
      params.require(:discount_plan).permit(:name, :start_at, :end_at, :enable_on_monday, :enable_on_tuesday, :enable_on_wednesday, :enable_on_thursday, :enable_on_friday, :enable_on_saturday, :enable_on_sunday,
        :discount_plan_items_attributes => [:id, :item_type, :discount, :category_ids_string, :variant_ids_string, :combo_ids_string, :_destroy])
    end

  end
end
