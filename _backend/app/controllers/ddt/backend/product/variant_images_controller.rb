module Ddt
  class Backend::Product::VariantImagesController < Backend::BaseController
    check_permission :branch, :variant_image, { index: :show, [:list, :add_exist_image, :create] => :create, :update_postion => :update, :destroy => :destroy}
    before_action :set_product
    before_action :set_variant
    layout lambda { params[:layout_name]||'ddt/layouts/backend/product' }
    def index
      @images = @variant.images
      respond_to do |format|
        format.html
        format.json { render :json => @images.map {|image| image.to_jq_upload(@variant)} }
      end
    end

    def list
      @q = Ddt::VariantImage.global.ransack(params[:q])
      @variant_images = @q.result.distinct.paginate(:page => params[:page])
      respond_to do |format|
        format.js
      end
    end

    def add_exist_image
      @image = Ddt::VariantImage.global.find(params[:exist_image_id])
      @variant.images << @image unless @variant.images.include?(@image)
      @variant.save!
      respond_to do |format|
        format.js
      end
    end

    def create
      hex_str = Digest::MD5.hexdigest(params[:variant_image][:attachment].tempfile.read)
      @image = Ddt::VariantImage.find_by(hex_str: hex_str)
      if @image.blank?
        image_params = variant_image_params.merge({shop_id: @current_shop.id, branch_id: @current_branch.id, hex_str: hex_str})
        @image = Ddt::VariantImage.create(image_params)
      end
      @variant.images << @image
      if @variant.save
        respond_to do |format|
          format.html {
            render :json => [@image.to_jq_upload(@variant)].to_json,
                  :content_type => 'text/html',
                  :layout => false
          }
          format.json {
            render json: { files: [@image.to_jq_upload(@variant)] }, status: :created
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end

    def destroy
      @link = @variant.variants_variant_images.link_on_image(params[:id])
      @link.destroy if @link.present?
      render :json => true
    end

    def change_position
      @link = @variant.variants_variant_images.link_on_image(params[:id])
      @link.change_position(params[:position])
      render :reset
    end


    private
    def variant_image_params
      params.require(:variant_image).permit(:attachment, :attachment_cache)
    end

    def set_product
      @product = @current_branch.products.find(params[:product_id])
    end

    def set_variant
      @variant = @product.variants_including_master.find(params[:variant_id])
    end

  end
end