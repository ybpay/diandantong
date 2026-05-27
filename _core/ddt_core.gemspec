# frozen_string_literal: true

version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'ddt_core'
  s.version     = version
  s.summary     = 'Core engine for diandantong restaurant SaaS.'
  s.description = 'Core engine for diandantong - models, services, auth, and base controllers.'

  s.required_ruby_version = '>= 3.2.0'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'
  s.license     = 'MIT'

  s.files        = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile"]
  s.require_path = 'lib'

  s.add_dependency 'rails', '>= 7.0'
  s.add_dependency 'friendly_id', '~> 5.5'
  s.add_dependency 'discard', '~> 1.3'
  s.add_dependency 'devise', '~> 4.9'
  s.add_dependency 'devise-async', '~> 2.0'
  s.add_dependency 'actionpolicy', '~> 0.7'
  s.add_dependency 'aasm', '~> 5.5'
  s.add_dependency 'acts_as_list', '~> 1.2'
  s.add_dependency 'ransack', '~> 4.1'
  s.add_dependency 'pagy', '~> 9.0'
  s.add_dependency 'rqrcode_png', '~> 0.1'
  s.add_dependency 'barby', '~> 0.6'
  s.add_dependency 'bcrypt', '~> 3.1'
  s.add_dependency 'sidekiq', '~> 8.1'
  s.add_dependency 'sinatra', '>= 3.0'
  s.add_dependency 'faraday', '~> 2.0'
  s.add_dependency 'multi_logger', '~> 0.1'
  s.add_dependency 'httparty', '~> 0.22'
  s.add_dependency 'faraday-cookie_jar', '~> 0.0.7'
  s.add_dependency 'settingslogic', '~> 2.0'
  s.add_dependency 'chinese_cities', '~> 0.0.4'
  s.add_dependency 'geocoder', '~> 1.8'
  s.add_dependency 'rest-client', '~> 2.1'
  s.add_dependency 'api-auth', '~> 2.5'
  s.add_dependency 'mini_magick', '~> 4.12'
  s.add_dependency 'htmlentities', '~> 4.3'
  s.add_dependency 'public_suffix', '~> 6.0'
  s.add_dependency 'ruby-pinyin', '~> 1.0'
  s.add_dependency 'spreadsheet', '~> 1.3'
  s.add_dependency 'yajl-ruby', '~> 1.4'
  s.add_dependency 'font-awesome-rails', '~> 4.5'
  s.add_dependency 'easy_captcha', '~> 0.6'
  s.add_dependency 'activerecord-import', '~> 2.1'
  s.add_dependency 'request_store', '~> 1.7'
  s.add_dependency 'rubyzip', '>= 1.3.0'
  s.add_dependency 'jpush'
  s.add_dependency 'redis', '~> 5.0'
  s.add_dependency 'connection_pool'
  s.add_dependency 'paper_trail', '~> 17.0'
  s.add_dependency 'impressionist', '~> 2.0'
  s.add_dependency 'doorkeeper', '~> 5.7'
end
