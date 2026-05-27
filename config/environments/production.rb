Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.year.to_i}",
    'Expires' => 1.year.from_now.httpdate
  }

  config.disable_app_notification = false

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]

  config.action_cable.disable_request_forgery_protection = true
  config.action_cable.url = ENV.fetch("ACTION_CABLE_URL", "wss://#{ENV.fetch('HOST', 'cy.diandantong.com')}/cable")
  config.action_cable.allowed_request_origins = [ENV.fetch("HOST", "cy.diandantong.com")]

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: ENV.fetch('HOST', 'cy.diandantong.com') }
  config.action_mailer.smtp_settings = {
    address: 'smtp.exmail.qq.com',
    port: 25,
    domain: 'diandantong.com',
    user_name: 'noreply@diandantong.com',
    password: Rails.application.credentials.dig(:smtp, :password) || 'ddt2013',
    authentication: :login,
    enable_starttls_auto: false
  }
  ActionMailer::Base.default from: "微信点单 <noreply@diandantong.com>"
  config.action_controller.default_url_options = { host: ENV.fetch('APP_HOST', 'cy.diandantong.com') }
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_HOST', 'cy.diandantong.com') }

  config.action_controller.asset_host = ENV.fetch("ASSET_HOST", "http://d.cache.diandantong.com")

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecations_silence = []

  config.active_record.dump_schema_after_migration = false

  config.active_storage.service = :amazon

  config.force_ssl = ENV.fetch("RAILS_FORCE_SSL", "true") == "true"

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.cache_store = :solid_cache_store
end
