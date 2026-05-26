source 'https://gems.ruby-china.com'

gem 'rails', '4.1.13'
gem 'mysql2', '0.3.17'
gem 'exception_notification', '~> 4.2.0'
gem 'jpush', "3.2.1"
gem 'foreman', '0.63.0'
gem 'uglifier'
gem 'paper_trail', '3.0.6'

gem 'settingslogic'
gem 'angularjs-rails'
gem 'puma'
gem 'thin'

gem 'sass-rails', '~> 5.0.6'
gem 'sprockets', '2.11.0'
gem 'rack-attack', '4.3.1'
gem 'ar-octopus'

gem 'activerecord-session_store', "0.1.2"
gem 'alipay'                        , '~> 0.17.0', git: 'https://github.com/chloerei/alipay.git'
gem 'eco'

group :development, :test do
  if $:.grep(/RubyMine/).empty?
    gem 'byebug'
  else
    gem 'ruby-debug-ide'
    gem 'debase'
  end
  gem 'quiet_assets'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'newrelic_rpm'
  gem 'spring'
end

group :test do
  gem 'database_cleaner', '~> 1.3'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'minitest-spec-rails', '~> 5.3.0'
  gem 'minitest-reporters', '~> 1.1.5'
  gem 'mocha', '~> 1.1.0'
end

gem 'ddt_core', path: './_core'
gem 'ddt_backend', path: './_backend'
gem 'ddt_weixin', path: './_weixin'
gem 'ddt_agentsys', path: './_agentsys'
gem 'ddt_webpos', path: './_webpos'
gem 'ddt_oauth_api', path: './_oauth_api'
gem 'ddt_common_api', path: './_common_api'
gem 'ddt_inner_api', path: './_inner_api'
gem 'auto_strip_attributes', '~> 2.0'
gem 'whenever', require: false
gem 'unicorn'
gem 'doorkeeper', '~> 3.1.0'
# gem 'rbtrace'
# gem 'marginalia' # log controller:action to mysql-slow-log
gem 'sqlite3'
