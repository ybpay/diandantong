# encoding: UTF-8
version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "ddt_weixin"
  s.version     = version
  s.summary     = 'The weixin for ddt.'
  s.description = 'The weixin for ddt.'
  s.required_ruby_version = '>= 1.9.3'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'
  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'


  s.add_dependency 'ddt_core'                  , version
  s.add_dependency 'turbolinks'                       , '~> 2.4.0'
  s.add_dependency 'impressionist'                    , '~> 1.5.1'
  # s.add_dependency 'haml'                             , '4.1.0.beta.1'
  # s.add_dependency 'haml-rails'                       , '~> 0.5.3'
  s.add_dependency 'hamlit'                          , '~> 1.7.1'
  s.add_dependency 'hamlit-rails'                      , '~> 0.1.0'
  s.add_dependency 'jquery-turbolinks'                , '~> 2.1.0'
  s.add_dependency 'angularjs-rails'
  s.add_dependency 'jbuilder'                         , '~> 2.0'
  s.add_dependency 'jquery-tmpl-rails'                , '~> 1.1.0'
  s.add_dependency 'geokit'
  s.add_dependency 'geokit-rails'
end
