#encoding: utf-8
module Ddt
  #可供下载的文件
  class DFile < Ddt::Base
    belongs_to :owner
    validates_presence_of :file_name, :file_path

    require 'carrierwave/orm/activerecord'
    mount_uploader :file_path, DFileUploader
  end
end
