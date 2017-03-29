# encoding: UTF-8
version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'ddt_backend'
  s.version     = version
  s.summary     = 'The backend for ddt.'
  s.description = 'The backend for ddt.'
  s.required_ruby_version = '>= 1.9.3'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'

  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'

  s.add_dependency 'ddt_core'                 , version
  s.add_dependency 'turbolinks'                      , '~> 2.4.0'
  s.add_dependency 'momentjs-rails'                  , '~> 2.5.1'
  s.add_dependency 'bootstrap3-datetimepicker-rails' , '3.0.0.2'
  s.add_dependency 'jquery-ui-rails'                 , '~> 5.0.0'
  s.add_dependency 'angularjs-rails'                 , '~> 1.3.15'
  s.add_dependency 'will_paginate-bootstrap'         , '~> 1.0.1'
  s.add_dependency 'impressionist'                   , '~> 1.5.1'
  s.add_dependency 'nested_form'                     , '~> 0.3.2'
  s.add_dependency 'select2-rails'                   , '3.5.9.1'
  s.add_dependency 'jquery-minicolors-rails'         , '~> 2.1.4'
  s.add_dependency 'simple_form'                     , '3.1.0.rc2'
  # s.add_dependency 'haml'                            , '4.1.0.beta.1'
  # s.add_dependency 'haml-rails'                      , '~> 0.5.3'
  s.add_dependency 'hamlit'                          , '~> 1.7.1'
  s.add_dependency 'hamlit-rails'                      , '~> 0.1.0'
  s.add_dependency 'bootstrap-sass'                  , '3.3.6'
  s.add_dependency 'jquery-turbolinks'               , '~> 2.1.0'
  s.add_dependency 'nprogress-rails'                 , '0.1.6.3'
  s.add_dependency 'rmagick'                         , '~> 2.13.1'
  s.add_dependency 'rails-i18n'                      , '~> 4.0.3'
  s.add_dependency 'remotipart'                      , '~> 1.2.1'
  s.add_dependency 'jquery-fileupload-rails'         , '0.4.1'
  s.add_dependency 'china_city'                      , '0.0.4'
  s.add_dependency 'jbuilder'                        , '~> 2.0'
  s.add_dependency 'highcharts-rails'                , '~> 4.0.4'
  s.add_dependency 'whenever'                        , '~> 0.9.4'
  s.add_dependency 'browser'                        , '~> 2.2.0'
end
