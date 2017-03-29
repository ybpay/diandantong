#encoding:utf-8
class Ddt::JPushConfig < Settingslogic
  source "#{Rails.root}/config/j_push.yml"
  namespace Rails.env
end