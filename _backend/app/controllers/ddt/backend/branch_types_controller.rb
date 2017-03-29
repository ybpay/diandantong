module Ddt
  class Backend::BranchTypesController < Backend::BaseController
    check_permission :shop, :branch_type, base_permission_actions.merge({:index_branch_nav => :show, [:edit_branch_nav, :update_branch_nav] => :update})
    before_action :set_branch_type, only: [:show, :edit, :update, :destroy, :edit_branch_nav, :update_branch_nav]

    def index
      @q = @current_shop.branch_types.ransack(params[:q])
      @branch_types = @q.result(distinct: true).paginate(page: params[:page])
    end



    def index_branch_nav
      @branch_types = @current_shop.branch_types
      render layout: 'ddt/layouts/backend/shop'
    end

    def edit_branch_nav
      render layout: 'ddt/layouts/backend/shop'
    end

    def update_branch_nav
      if @branch_type.update(branch_type_params)
        redirect_to [:index_branch_nav, :backend, @current_shop, :branch_types], notice: "#{t('activerecord.models.ddt/branch_type')} 更新成功."
      else
        render :edit_branch_nav, layout: 'ddt/layouts/backend/shop'
      end
    end

    def show
      @q = @branch_type.branches.ransack(params[:q])
      @branches = @q.result(distinct: true).paginate(page: params[:page])
    end

    def new
      @branch_type = @current_shop.branch_types.build
    end

    def edit
    end

    def create
      @branch_type = @current_shop.branch_types.build(branch_type_params)

      if @branch_type.save
        redirect_to [:backend, @current_shop, @branch_type], notice: "#{t('activerecord.models.ddt/branch_type')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @branch_type.update(branch_type_params)
        redirect_to [:backend, @current_shop, @branch_type], notice: "#{t('activerecord.models.ddt/branch_type')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @branch_type.destroy
        redirect_to backend_shop_branch_types_url(@current_shop), notice: "#{t('activerecord.models.ddt/branch_type')} 删除成功."
      else
        flash[:error] = @branch_type.errors.full_messages.join(", ")
        redirect_to backend_shop_branch_types_url(@current_shop)
      end
    end

    private
      def set_branch_type
        @branch_type = @current_shop.branch_types.find(params[:id])
      end

      def branch_type_params
        params.require(:branch_type).permit(:name, :icon, :bg_color, :image, :image_cache, :remove_image,
          :show_reservation_img,
          :reservation_img_text,
          :reservation_img,
          :remove_reservation_img,
          :reservation_img_cache,

          :show_order_in_seat_img,
          :order_in_seat_img_text,
          :order_in_seat_img,
          :remove_order_in_seat_img,
          :order_in_seat_img_cache,

          :show_delivery_img,
          :delivery_img_text,
          :delivery_img,
          :remove_delivery_img,
          :delivery_img_cache,

          :show_queue_img,
          :queue_img_text,
          :queue_img,
          :remove_queue_img,
          :queue_img_cache,

          :show_pay_online_img,
          :pay_online_img_text,
          :pay_online_img,
          :remove_pay_online_img,
          :pay_online_img_cach,

          :show_fastfood_img,
          :fastfood_img_text,
          :fastfood_img,
          :remove_fastfood_img,
          :fastfood_img_cach,


          :show_wifi,
          :show_parking)
      end
  end
end
