module Ddt
  module Backend
    module Crm
      class CouponPhotosController < Backend::BaseCrmController
        check_permission :shop, :coupon_version, { [:index] => :show, [:create, :batch_destroy] => :update }
        before_action :set_coupon_version
        def index
          @coupon_photos = @coupon_version.coupon_photos
          render json: @coupon_photos.map{|p| { id: p.id, image: p.image }}
        end

        def create
          @coupon_photo = @coupon_version.coupon_photos.build(coupon_photo_params)
          if @coupon_photo.save
            render json: { id: @coupon_photo.id, image: @coupon_photo.image }
          else
            render json: { errors: @coupon_photo.errors.full_messages }, status: :bad_request
          end
        end

        def batch_destroy
          @coupon_photos = @coupon_version.coupon_photos.where(id: params[:photo_ids])
          @coupon_photos.each do |photo|
            photo.destroy
          end
          render json: {}
        end

        private
          def set_coupon_version
            @coupon_version = @current_shop.coupon_versions.find(params[:coupon_version_id])
          end
          def coupon_photo_params
            params.require(:coupon_photo).permit(:image)
          end
      end
    end
  end
end
