# encoding:utf-8
# 便于控制台操作
#
# 1. 使用 ddb::User 获取 User 对象
#

if defined? Rails::Console

  # 修复使用 Rails console 时某些文件无法识别的问题
  Dir["#{Rails.root}/_api/app/models/ddt/oapi/entities/*.rb"].each do |f|
    require f
  end

  require "#{Rails.root}/_core/app/models/ddt/notification.rb"
  Dir["#{Rails.root}/_core/app/models/ddt/notification/action/*.rb"].each do |f|
    require f
  end

  if Rails.env.development?
    def ddb
      Ddt
    end

    Hirb.enable
    include Ddt
  end

end