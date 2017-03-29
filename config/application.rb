require File.expand_path('../boot', __FILE__)
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Ddt
  class Application < Rails::Application

    # enable collect GC status
    # GC::Profiler.enable

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
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
  end
end

WillPaginate.per_page = 20
Date::DATE_FORMATS[:default] = "%Y-%m-%d"
Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M"
DateTime::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M"
