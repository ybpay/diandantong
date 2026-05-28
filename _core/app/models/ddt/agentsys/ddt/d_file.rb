#encoding: utf-8
module Ddt
  #可供下载的文件
  class DFile < Ddt::Base
    belongs_to :owner
    validates_presence_of :file_name, :file_path

    include Ddt::Attachable
    attachable_one :file_path
  end
end
