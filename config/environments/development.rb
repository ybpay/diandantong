Rails.application.configure do
  config.show_swagger_ui = true

  config.cache_classes = false
  config.eager_load = false

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.disable_app_notification = true

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load

  config.action_controller.default_url_options = { host: (ENV["DDB_HOST"] || "localhost:3000") }
  config.action_mailer.default_url_options = { host: (ENV["DDB_HOST"] || "localhost:3000") }
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
  ActionMailer::Base.default :from => "点单通 <noreply@diandantong.com>"

  config.active_storage.service = :local

  config.require_master_key = false

  # Raise error on unpermitted parameters
  config.action_controller.action_on_unpermitted_parameters = :log
end
