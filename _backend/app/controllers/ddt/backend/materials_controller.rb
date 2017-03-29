module Ddt
  class Backend::MaterialsController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage
    before_action :set_material, only: [:show, :edit, :update, :destroy]
    helper Ddt::Backend::ShopsHelper

    def index
      @materials = @current_shop.materials
    end

    def new
      @material = @current_shop.materials.new
      @material.msg_type = params[:type]
      respond_to do |format|
        format.html
      end
    end

    def edit
      if @material.articles.size == 0
        @article = @material.articles.build
        @article.shop_id = @current_shop.id
        @article.save(validate: false)
      else
        @article = @material.articles.first
      end
      respond_to do |format|
        format.html
      end
    end

    def create
      @material = @current_shop.materials.build(material_params)
      respond_to do |format|
        if @material.save
          format.html {
            if @material.is_news?
              redirect_to edit_backend_shop_material_path(@current_shop.slug, @material)
            else
              redirect_to backend_shop_materials_path(@current_shop.slug), notice: '素材创建成功'
            end
          }
        else
          format.html { render action: 'new' }
        end
      end
    end

    def update
      respond_to do |format|
        if @material.update(material_params)
          format.html { redirect_to backend_shop_materials_path(@current_shop.slug), notice: '素材更新成功' }
        else
          format.html { render action: 'edit' }
        end
      end
    end

    def destroy
      @material.destroy
      respond_to do |format|
        format.js
      end
    end

    def choose_material
      @materials = Ddt::Material.valid_materials(@current_shop.materials)
      @mask_pub = true
    end

    def show
    end

    private
      def set_material
        @material = @current_shop.materials.find(params[:id])
      end

      def material_params
        params.require(:material).permit(:msg_type, :material_name, :content, :title, :description, :music_url, :hq_music_url)
      end
  end
end
