Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = true

  config.disable_app_notification = false

  config.log_level = :info

  config.active_storage.service = :production

  config.action_controller.asset_host = ENV.fetch("ASSET_HOST", "http://d.cache.diandantong.com")

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.smtp_settings = {
    address:              'smtp.exmail.qq.com',
    port:                 25,
    domain:               'diandantong.com',
    user_name:            'noreply@diandantong.com',
    password:             ENV.fetch('SMTP_PASSWORD', 'ddt2013'),
    authentication:       :login,
    enable_starttls_auto: false
  }
  ActionMailer::Base.default :from => "微信点单 <noreply@diandantong.com>"
  config.action_controller.default_url_options = { host: ENV.fetch('APP_HOST', 'cy.diandantong.com') }
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_HOST', 'cy.diandantong.com') }

  # Do not dump schema after migrations (Rails 8 default)
  config.active_record.dump_schema_after_migration = false
end
