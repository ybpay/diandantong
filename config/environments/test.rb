Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false
  config.cache_classes = true

  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }

  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.action_dispatch.show_exceptions = :rescuable
  config.action_controller.allow_forgery_protection = false

  config.active_storage.service = :test

  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_caching = false

  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecations_silence = []

  config.active_record.encryption.primary_key = "test"
  config.active_record.encryption.deterministic_key = "test"
  config.active_record.encryption.key_derivation_salt = "test"

  config.action_controller.default_url_options = { host: 'www.example.com:80' }
  config.action_mailer.default_url_options = { host: 'www.example.com' }
end
