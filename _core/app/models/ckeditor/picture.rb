class Ckeditor::Picture < Ckeditor::Asset
  has_one_attached :data_file

  def url(*args)
    data_file.attached? ? Rails.application.routes.url_helpers.rails_blob_path(data_file, only_path: true) : nil
  end

  def url_content
    url
  end

  def filename
    data_file_name
  end
end
