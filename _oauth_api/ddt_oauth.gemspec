version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "ddt_oauth_api"
  s.version     = version
  s.summary     = 'The oauth api for ddt.'
  s.description = 'The oauth api for ddt.'
  s.required_ruby_version = '>= 3.2.0'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'
  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'


  s.add_dependency 'ddt_core'                  , version
  s.add_dependency 'doorkeeper'                  , '~> 5.7'
  s.add_dependency 'oauth2'                  , '~> 2.0'
end
