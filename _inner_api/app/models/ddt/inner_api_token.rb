#encoding: utf-8
class Ddt::InnerApiToken < Settingslogic
  source "#{Rails.root}/config/inner_api_token.yml"
  namespace Rails.env
end