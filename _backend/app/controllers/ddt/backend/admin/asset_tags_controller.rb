#encoding: utf-8
module Ddt
  module Backend
    class Admin::AssetTagsController < Ddt::Backend::BaseAdminController
      skip_before_action :check_admin_auth, only: [:index]
      before_action :set_asset_tag, only: [:edit, :update]
      def index
        @q = Ddt::AssetTag.all.ransack(params[:q])
        @asset_tags = @q.result.distinct.paginate(page: params[:page])
        respond_to do |format|
          format.html
          format.json {
            if params[:mode] == "tag"
              render :json => @asset_tags.map(&:tag_json)
            else
              render :json => @asset_tags.map(&:select_json)
            end
          }
        end
      end

      def new

      end

      def create
        @asset_tag = Ddt::AssetTag.new(asset_tag_params)
        if @asset_tag.save
          redirect_to [:backend, :asset_tags]
        else
          render :new
        end
      end

      def edit

      end

      def update
        if @asset_tag.update(asset_tag_params)
          redirect_to [:backend, :asset_tags]
        else
          render :edit
        end
      end

      def destroy
        @asset_tag.destroy
        redirect_to [:backend, :asset_tags]
      end

      private
      def asset_tag_params
        params.require(:asset_tag).permit(:name)
      end

      def set_asset_tag
        @asset_tag = Ddt::AssetTag.find(params[:id])
      end
    end
  end
end
