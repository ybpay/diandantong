class Ckeditor::PicturesController < Ckeditor::ApplicationController
  helper_method :next_page_url
  respond_to :html

  def index
    @pictures = Ckeditor.picture_adapter.find_all(ckeditor_pictures_scope(assetable: current_account))
    @pictures = Ckeditor::Paginatable.new(@pictures).page(params[:page])
    respond_with(@pictures, :layout => @pictures.first_page?)
  end

  def create
    @picture = Ckeditor.picture_model.new
    respond_with_asset(@picture)
  end

  def destroy
    @picture.destroy
    respond_with(@picture, :location => pictures_path)
  end

  protected

    def find_asset
      @picture = Ckeditor.picture_adapter.get!(params[:id])
    end

    def authorize_resource
      model = (@picture || Ckeditor.picture_model)
      @authorization_adapter.try(:authorize, params[:action], model)
    end

    def next_page_url
      url_for(params.merge(:page => @pictures.next_page))
    end
end