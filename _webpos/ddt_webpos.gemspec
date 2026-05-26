# encoding: UTF-8
version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "ddt_webpos"
  s.version     = version
  s.summary     = 'The webpos for ddt.'
  s.description = 'The webpos for ddt.'
  s.required_ruby_version = '>= 3.0.0'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'
  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'


  s.add_dependency 'ddt_core'                  , version
  s.add_dependency 'turbolinks'                       , '~> 5.2.0'
  s.add_dependency 'jquery-turbolinks'                , '~> 2.1.0'
  s.add_dependency 'angularjs-rails'                  , '~> 1.3.15'
  s.add_dependency 'jbuilder'                         , '~> 2.7'
  s.add_dependency 'will_paginate-bootstrap'         , '~> 1.0.1'
  s.add_dependency 'hamlit'                          , '~> 2.9.0'
  s.add_dependency 'hamlit-rails'                      , '~> 0.2.0'
  s.add_dependency 'bootstrap-sass'                  , '~> 3.4.0'
  s.add_dependency 'highcharts-rails'                , '~> 4.0.4'
end
