module Ddt
  module Backend
    module Crm
      class CouponVersionsController < Backend::BaseCrmController
        check_permission :shop, :coupon_version
        before_action :set_coupon_version, only: [:show, :edit, :update, :destroy]

        def index
          @q = @current_shop.coupon_versions.includes(:coupon_usage_instructions, :coupon_photos).ransack(params[:q])
          @coupon_versions = @q.result.paginate(page: params[:page])
        end

        def show
        end

        def create
          @coupon_version = @current_shop.coupon_versions.build(coupon_version_params)

          # 以下用以修改新建时，提示 shop_id 不存在以及图片无效的 bug
          @coupon_version.coupon_photos.each do |it|
            it.shop_id = @current_shop.id
          end

          if @coupon_version.save
            render :show
          else
            render json: { errors: @coupon_version.errors.full_messages }, status: :bad_request
          end
        end

        def update
          if @coupon_version.update(coupon_version_params)
            render :show
          else
            render json: { errors: @coupon_version.errors.full_messages }, status: :bad_request
          end
        end

        def destroy
          if @coupon_version.destroy
            render json: {}
          else
            render json: { errors: @coupon_version.errors.full_messages }, status: :bad_request
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
  end
end
