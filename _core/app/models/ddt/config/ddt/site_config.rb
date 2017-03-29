#encoding: utf-8
class Ddt::SiteConfig < Settingslogic
  source "#{Rails.root}/config/site_config.yml"
  namespace Rails.env
end