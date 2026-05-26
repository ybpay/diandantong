version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "ddt_common_api"
  s.version     = version
  s.summary     = 'The common api for ddt.'
  s.description = 'The common api for ddt.'
  s.required_ruby_version = '>= 3.2.0'
  s.author      = 'ddt'
  s.email       = 'xie_s@diandantong.com'
  s.homepage    = 'http://www.diandantong.com'
  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'


  s.add_dependency 'ddt_core'                  , version
end
