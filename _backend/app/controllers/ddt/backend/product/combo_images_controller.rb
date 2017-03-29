module Ddt
  class Backend::Product::ComboImagesController < Backend::BaseController
    check_permission :branch, :combo_image, { index: :show, [:list, :add_exist_image, :create] => :create, :update_postion => :update, :destroy => :destroy}
    before_action :set_combo
    layout lambda { params[:layout_name]||'ddt/layouts/backend/combo' }
    def index
      @images = @combo.images
      respond_to do |format|
        format.html
        format.json { render :json => @images.map {|image| image.to_jq_upload(@combo)} }
      end
    end

    def list
      @q = Ddt::ComboImage.global.ransack(params[:q])
      @combo_images = @q.result.distinct.paginate(:page => params[:page])
      respond_to do |format|
        format.js
      end
    end

    def add_exist_image
      @image = Ddt::ComboImage.global.find(params[:exist_image_id])
      @combo.images << @image unless @combo.images.include?(@image)
      @combo.save!
      respond_to do |format|
        format.js
      end
    end

    def create
      hex_str = Digest::MD5.hexdigest(params[:combo_image][:attachment].tempfile.read)
      @image = Ddt::ComboImage.find_by(hex_str: hex_str)
      if @image.blank?
        image_params = combo_image_params.merge({shop_id: @current_shop.id, branch_id: @current_branch.id, hex_str: hex_str})
        @image = Ddt::ComboImage.create(image_params)
      end
      @combo.images << @image
      if @combo.save
        respond_to do |format|
          format.html {
            render :json => [@image.to_jq_upload(@combo)].to_json,
                  :content_type => 'text/html',
                  :layout => false
          }
          format.json {
            render json: { files: [@image.to_jq_upload(@combo)] }, status: :created
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end

    def destroy
      @link = @combo.combos_combo_images.link_on_image(params[:id])
      @link.destroy if @link.present?
      render :json => true
    end

    def change_position
      @link = @combo.combos_combo_images.link_on_image(params[:id])
      @link.change_position(params[:position])
      render :reset
    end


    private
    def combo_image_params
      params.require(:combo_image).permit(:attachment, :attachment_cache)
    end

    def set_combo
      @combo = @current_branch.combos.find(params[:combo_id])
    end

  end
end
