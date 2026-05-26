# encoding: UTF-8
version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "ddt_agentsys"
  s.version     = version
  s.summary     = 'The agentsys for ddt.'
  s.description = 'The agentsys for ddt.'
  s.required_ruby_version = '>= 3.2.0'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'
  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'

  s.add_dependency 'ddt_core'                  , version
  s.add_dependency 'impressionist'                    , '~> 2.0'
  s.add_dependency 'hamlit'                          , '~> 2.9.0'
  s.add_dependency 'hamlit-rails'                    , '~> 0.2.0'
  s.add_dependency 'jbuilder'                         , '~> 2.7'
end
