class Ckeditor::Asset < ActiveRecord::Base
  replicated_model

  include Ckeditor::Orm::ActiveRecord::AssetBase

  delegate :url, :current_path, :content_type, :to => :data

  validates_presence_of :data
end
