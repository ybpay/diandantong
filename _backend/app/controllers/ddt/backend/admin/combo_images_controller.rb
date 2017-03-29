#encoding: utf-8
module Ddt
  module Backend
    class Admin::ComboImagesController < Ddt::Backend::BaseAdminController
      before_action :set_combo_image, only: [:edit, :update]
      def index
        @q = Ddt::ComboImage.includes(:asset_tags, :combos).ransack(params[:q])
        @combo_images = @q.result(distinct: true).paginate(page: params[:page])
      end

      def new
        @combo_image = Ddt::ComboImage.new
      end

      def create
        @combo_image = Ddt::ComboImage.new(combo_image_params)
        if @combo_image.save
          render :reset
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @combo_image.update(combo_image_params)
          render :reset
        else
          render :edit
        end
      end

      def batch_set
        @combo_images = Ddt::ComboImage.includes(:asset_tags, :combos => [:product]).find(params[:combo_image][:combo_image_ids])
        @combo_images.each do |image|
          image.set_global
        end
        render :batch_set
      end

      private
      def combo_image_params
        params.require(:combo_image).permit(:is_global, :asset_tag_id, :attachment, :asset_tag_names, :combo_image_ids => [])
      end

      def set_combo_image
        @combo_image = Ddt::ComboImage.find(params[:id])
      end
    end
  end
end
