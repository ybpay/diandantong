source 'https://gems.ruby-china.com'

gem 'rails', "4.1.13"
gem 'mysql2'
gem 'sqlite3'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sass-rails', '>= 3.2'
gem 'coffee-rails'
gem 'uglifier', '>= 1.2.4'

group :test, :development do
  gem 'byebug' if $:.grep(/RubyMine/).empty?
  gem 'railroady'
  gem 'quiet_assets'
  gem 'database_cleaner', '~> 1.3'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'minitest-spec-rails', '~> 5.3.0'
  gem 'minitest-reporters', '~> 1.1.5'
end