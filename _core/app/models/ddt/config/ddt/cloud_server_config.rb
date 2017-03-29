#encoding:utf-8
class Ddt::CloudServerConfig < Settingslogic
  source "#{Rails.root}/config/cloud_server.yml"
  namespace Rails.env
end