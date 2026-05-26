#encoding: utf-8
Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = true

  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true

  config.disable_app_notification = false
  config.assets.version = '1.0'

  config.log_level = :info

  config.action_controller.asset_host = "http://d.cache.diandantong.com"

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.smtp_settings = {
    address:              'smtp.exmail.qq.com',
    port:                 25,
    domain:               'diandantong.com',
    user_name:            'noreply@diandantong.com',
    password:             'ddt2013',
    authentication:       :login,
    enable_starttls_auto: false
  }
  ActionMailer::Base.default :from => "微信点单 <noreply@diandantong.com>"
  config.action_controller.default_url_options = { host: 'cy.diandantong.com' }
  config.action_mailer.default_url_options = { host: 'cy.diandantong.com' }
end
