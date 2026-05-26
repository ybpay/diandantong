version = File.read(File.expand_path("../../DIANDANTONG_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "ddt_inner_api"
  s.version     = version
  s.authors     = ["ddt"]
  s.email       = ["dev@diandantong.com"]
  
  s.homepage    = "http://www.diandantong.com"
  s.summary     = "The inner api of ddt"
  s.description = "The inner api of ddt"
  s.required_ruby_version = '>= 3.2.0'
  s.files        = Dir["{app,config,db,lib,vendor}/**/*"]
  s.require_path = 'lib'


  s.add_dependency 'ddt_core'                  , version
end
