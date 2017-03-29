module Ddt
  class Backend::VoucherVersionsController < Backend::BaseController
    check_permission :shop, :voucher_version
    before_action :set_voucher_version, only: [:show, :edit, :update, :destroy]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/groupon' }

    def index
      @q = @current_shop.voucher_versions.ransack(params[:q])
      @voucher_versions = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def new
      @voucher_version = @current_shop.voucher_versions.build
    end

    def edit
    end

    def create
      @voucher_version = @current_shop.voucher_versions.build(voucher_version_params)

      if @voucher_version.save
        redirect_to [:backend, @current_shop, @voucher_version], notice: "#{t('activerecord.models.ddt/voucher_version')} 创建成功."
      else
        render :new
      end
    end

    def update
      if @voucher_version.update(voucher_version_params)
        redirect_to [:backend, @current_shop, @voucher_version], notice: "#{t('activerecord.models.ddt/voucher_version')} 更新成功."
      else
        render :edit
      end
    end

    def destroy
      if @voucher_version.destroy
        redirect_to backend_shop_voucher_versions_url(@current_shop), notice: "#{t('activerecord.models.ddt/voucher_version')} 删除成功."
      else
        flash[:error] = @voucher_version.errors.full_messages.join('<br/>')
        redirect_to backend_shop_voucher_versions_url(@current_shop)
      end
    end

    private
      def set_voucher_version
        @voucher_version = @current_shop.voucher_versions.find(params[:id])
      end

      def voucher_version_params
        params.require(:voucher_version).permit(:name, :show_on_index, :usable_starts_at, :usable_expires_at,
           :sellable_starts_at, :sellable_expires_at, :max_grant_limit, :max_count_each_user, :coupon_appliable_branch_scope_policy, :base_coupons_count,
          :refund_coupons_count, :used_coupons_count, :groupon_price, :norminal_value, :description,
          :applicaple_product_scope, :branch_ids_string, :support_refund, :refundable_days_after_send,
          :coupon_photos_attributes => [:id, :image, :image_cache, :_destroy],
          :coupon_usage_instructions_attributes => [:id, :content, :_destroy])
      end
  end
end
