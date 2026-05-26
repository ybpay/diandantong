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
