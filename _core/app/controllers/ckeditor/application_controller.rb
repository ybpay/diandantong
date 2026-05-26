# Stub for Ckeditor::ApplicationController (ckeditor gem removed in Phase 6).
# Provides the base functionality needed by Ckeditor::PicturesController
# until the full Vue 3 migration replaces the rich text editor.
class Ckeditor::ApplicationController < ApplicationController
  protect_from_forgery with: :null_session

  private

  def respond_with_asset(asset)
    file = params[:upload] || params[:qqfile]
    asset.data_file.attach(io: file.tempfile, filename: file.original_filename, content_type: file.content_type)
    asset.save

    respond_to do |format|
      format.html { render plain: asset.url }
      format.json { render json: { uploaded: 1, fileName: file.original_filename, url: asset.url } }
    end
  end

  def ckeditor_pictures_scope(assetable:)
    Ckeditor::Picture.where(assetable: assetable)
  end
end
