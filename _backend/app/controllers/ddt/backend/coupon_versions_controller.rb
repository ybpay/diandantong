module Ddt
  class Backend::CouponVersionsController < Backend::BaseController
    check_permission :shop, :coupon_version
    before_action :set_coupon_version, only: [:show, :edit, :update, :destroy]
    layout 'ddt/layouts/backend/coupon_version'

    def index
      @q = @current_shop.coupon_versions.ransack(params[:q])
      @coupon_versions = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @coupon_version = @current_shop.coupon_versions.build
    end

    def edit
    end

    def create
      @coupon_version = @current_shop.coupon_versions.build(coupon_version_params)

      # 以下用以修改新建时，提示 shop_id 不存在以及图片无效的 bug
      @coupon_version.coupon_photos.each do |it|
        it.shop_id = @current_shop.id
      end

      if @coupon_version.save
        redirect_to [:backend, @current_shop, @coupon_version], notice: "#{t('activerecord.models.ddt/coupon_version')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @coupon_version.update(coupon_version_params)
        redirect_to [:backend, @current_shop, @coupon_version], notice: "#{t('activerecord.models.ddt/coupon_version')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @coupon_version.destroy
        redirect_to backend_shop_coupon_versions_url(@current_shop), notice: "#{t('activerecord.models.ddt/coupon_version')} 删除成功."
      else
        flash[:error] = @coupon_version.errors.full_messages.join('<br/>')
        redirect_to backend_shop_coupon_versions_url(@current_shop)
      end
    end

    private
      def set_coupon_version
        @coupon_version = @current_shop.coupon_versions.find(params[:id])
      end

      def coupon_version_params
        params.require(:coupon_version).permit(
            :name, :usable_starts_at, :usable_expires_at, :max_grant_limit, :can_exchange, :credit_count,
            :coupon_appliable_branch_scope_policy, :norminal_value, :coupon_min_usable_amount, :usable_days_after_send, :expired_type,
            :description, :branch_ids_string, :max_count_each_user, :support_delivery, :support_eat_in_hall, :coupon_type, :product_sku,
          :coupon_usage_instructions_attributes => [:id, :content, :_destroy],
          :coupon_photos_attributes => [:id, :image, :image_cache, :_destroy])
      end
  end
end
