Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false

  config.consider_all_requests_local = true
  config.server_timing = true

  config.action_controller.perform_caching = true
  config.action_controller.enable_fragment_cache_logging = true

  config.cache_store = :memory_store
  config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{2.days.to_i}" }

  config.show_swagger_ui = true
  config.disable_app_notification = true

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: ENV.fetch("DDB_HOST", "localhost:3000") }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.exmail.qq.com',
    port: 25,
    domain: 'diandantong.com',
    user_name: 'noreply@diandantong.com',
    password: Rails.application.credentials.dig(:smtp, :password) || 'ddt2013',
    authentication: :login,
    enable_starttls_auto: false
  }
  ActionMailer::Base.default from: "点单通 <noreply@diandantong.com>"

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecations_silence = []

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.active_storage.service = :local

  config.assets.debug = false

  config.require_master_key = false

  # Raise error on unpermitted parameters
  config.action_controller.action_on_unpermitted_parameters = :log

  config.hosts << /.+\.ngrok\.io/
  config.hosts << /.+\.trycloudflare\.com/
end
