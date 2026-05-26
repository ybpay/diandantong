require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(:default, Rails.env)

module Ddt
  class Application < Rails::Application

    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :"zh-CN"
    config.time_zone = 'Asia/Shanghai'
    config.i18n.load_path += Dir["#{config.root}/_core/config/locals/*.yml"]
    config.i18n.load_path += Dir["#{config.root}/_backend/config/locals/*.yml"]

    config.active_record.default_timezone = :local
    config.autoload_paths += %W(#{config.root}/app/models)
    config.eager_load_paths += Dir["#{config.root}/app/models/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    config.assets.precompile = [ /\A[^\/\\]+\.(css|scss|js)$/i ]
    config.generators do |g|
      g.template_engine :haml
      g.stylesheets     false
      g.javascripts     false
      g.jbuilder        false
      g.helper          false
      g.test_framework    nil
    end
    config.exceptions_app = self.routes
    config.dev_mail_group = 'dev@diandantong.com'
    config.supervisor_mail = 'xie_s@diandantong.com'
    config.salers_mail = 'sales@diandantong.com'
    config.customer_service_group = 'cs@diandantong.com'
    config.worker_mail = 'cb@diandantong.com'

    # config.middleware.use Rack::Attack

    config.log_formatter = ::Logger::Formatter.new
    config.log_formatter.datetime_format = '%F %T'

    # Load defaults from 5.0 for backward compatibility, with targeted overrides
    config.load_defaults 5.0

    # Rails 5.1+ defaults (override selectively)
    config.active_record.belongs_to_required_by_default = false

    # Rails 5.2+ defaults
    config.active_record.cache_versioning = true
    config.active_record.collection_cache_versioning = true
    config.active_support.hash_digest_class = OpenSSL::Digest::SHA1
    config.active_support.use_authenticated_message_encryption = false

    # Rails 6.0 defaults
    config.autoloader = :zeitwerk
    config.action_controller.default_protect_from_forgery = false
    config.action_dispatch.use_cookies_with_metadata = false
    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

WillPaginate.per_page = 20
Date::DATE_FORMATS[:default] = "%Y-%m-%d"
Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M"
DateTime::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M"
