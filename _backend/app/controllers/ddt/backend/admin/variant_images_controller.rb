#encoding: utf-8
module Ddt
  module Backend
    class Admin::VariantImagesController < Ddt::Backend::BaseAdminController
      before_action :set_variant_image, only: [:edit, :update]
      def index
        @q = Ddt::VariantImage.includes(:asset_tags, :variants => [:product]).ransack(params[:q])
        @variant_images = @q.result(distinct: true).paginate(page: params[:page])
      end

      def new
        @variant_image = Ddt::VariantImage.new
      end

      def create
        @variant_image = Ddt::VariantImage.new(variant_image_params)
        if @variant_image.save
          render :reset
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @variant_image.update(variant_image_params)
          render :reset
        else
          render :edit
        end
      end

      def batch_set
        @variant_images = Ddt::VariantImage.includes(:asset_tags, :variants => [:product]).find(params[:variant_image][:variant_image_ids])
        @variant_images.each do |image|
          image.set_global
        end
        render :batch_set
      end

      private
      def variant_image_params
        params.require(:variant_image).permit(:is_global, :asset_tag_id, :attachment, :asset_tag_names, :variant_image_ids => [])
      end

      def set_variant_image
        @variant_image = Ddt::VariantImage.find(params[:id])
      end
    end
  end
end