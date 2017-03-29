module Ddt
  class Backend::GrouponVersionsController < Backend::BaseController
    check_permission :shop, :groupon_version, base_permission_actions.merge({choose_groupon_branch: :create})
    before_action :set_groupon_version, only: [:show, :edit, :update, :destroy]
    layout 'ddt/layouts/backend/groupon'

    def index
      @q = @current_shop.groupon_versions.ransack(params[:q])
      @groupon_versions = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @groupon_version = @current_shop.groupon_versions.build
      @groupon_version.coupon_usage_instructions.build
      @groupon_version.coupon_photos.build
    end

    def edit
    end

    def create
      @groupon_version = @current_shop.groupon_versions.build(groupon_version_params)
      @groupon_version.coupon_photos.each{|coupon_photo| coupon_photo.shop = @current_shop}

      if @groupon_version.save
        @current_shop.touch
        redirect_to [:backend, @current_shop, @groupon_version], notice: "#{t('activerecord.models.ddt/groupon_version')} 创建成功."
      else
        render :new
      end
    end

    def update
      @groupon_version.attributes = groupon_version_params
      @groupon_version.coupon_photos.each{|coupon_photo| coupon_photo.shop = @current_shop}
      if @groupon_version.save
        @current_shop.touch
        redirect_to [:backend, @current_shop, @groupon_version], notice: "#{t('activerecord.models.ddt/groupon_version')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @groupon_version.destroy
        redirect_to backend_shop_groupon_versions_url(@current_shop), notice: "#{t('activerecord.models.ddt/groupon_version')} 删除成功."
      else
        flash[:error] = @groupon_version.errors.full_messages.join('<br/>')
        redirect_to backend_shop_groupon_versions_url(@current_shop)
      end
    end

    private
      def set_groupon_version
        @groupon_version = @current_shop.groupon_versions.find(params[:id])
      end

      def groupon_version_params
        params.require(:groupon_version).permit(:name, :show_on_index, :usable_starts_at, :usable_expires_at, :sellable_starts_at, :sellable_expires_at,
          :max_grant_limit, :max_count_each_user, :coupon_appliable_branch_scope_policy, :base_coupons_count, :refund_coupons_count,
          :used_coupons_count, :groupon_price, :description, :support_refund, :refundable_days_after_send, :branch_ids_string, :norminal_value,
          :coupon_photos_attributes => [:id, :image, :image_cache, :_destroy],
          :coupon_usage_instructions_attributes => [:id, :content, :_destroy])
      end
  end
end
