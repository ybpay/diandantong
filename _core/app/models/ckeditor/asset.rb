class Ckeditor::Asset < ActiveRecord::Base
  self.table_name = 'ckeditor_assets'

  has_one_attached :data_file

  validates_presence_of :data_file_name
end
