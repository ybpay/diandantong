require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Ddt
  class Application < Rails::Application
    config.load_defaults 8.1

    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :"zh-CN"
    config.time_zone = 'Asia/Shanghai'
    config.i18n.load_path += Dir["#{config.root}/_core/config/locals/*.yml"]
    config.i18n.load_path += Dir["#{config.root}/_backend/config/locals/*.yml"]

    config.active_record.default_timezone = :local

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators do |g|
      g.template_engine :haml
      g.stylesheets     false
      g.javascripts     false
      g.jbuilder        false
      g.helper          false
      g.test_framework :rspec, {
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      }
    end

    config.exceptions_app = self.routes

    # config.middleware.use Rack::Attack

    config.active_record.strict_loading_by_default = true

    config.active_job.queue_adapter = :solid_queue

    config.active_storage.service = :local

    config.action_controller.default_protect_from_forgery = true

    config.log_formatter = ::Logger::Formatter.new
    config.log_formatter.datetime_format = '%F %T'

    # Load Rails 8.1 defaults
    config.load_defaults 8.1

    # Backward compatibility overrides
    config.active_record.belongs_to_required_by_default = false
    config.action_controller.default_protect_from_forgery = false
  end
end

Pagy::DEFAULT[:items] = 20

Date::DATE_FORMATS[:default] = "%Y-%m-%d"
Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M"
DateTime::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M"
