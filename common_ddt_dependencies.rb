source 'https://gems.ruby-china.com'

gem 'rails', '~> 8.1.0'
gem 'pg', '~> 1.5'
gem 'exception_notification', '~> 5.0'
gem 'jpush', '3.2.1'
gem 'paper_trail', '~> 17.0'

gem 'settingslogic'
gem 'puma', '~> 7.0'

gem 'propshaft'
gem 'rack-attack', '~> 6.0'

gem 'activerecord-session_store', '~> 2.0'
gem 'alipay', '~> 0.17.0', git: 'https://github.com/chloerei/alipay.git'
gem 'bootsnap', '>= 1.18.0', require: false

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'newrelic_rpm'
  gem 'spring'
  gem 'listen', '~> 3.2'
end

group :test do
  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'minitest-spec-rails', '~> 5.3.0'
  gem 'minitest-reporters', '~> 1.1.5'
  gem 'mocha', '~> 2.0'
  gem 'rails-controller-testing'
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
gem 'doorkeeper', '~> 5.7'
gem 'responders', '~> 3.0'
