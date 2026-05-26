source 'https://gems.ruby-china.com'

gem 'rails', "~> 5.0.7"
gem 'mysql2', '>= 0.3.18', '< 0.6'
gem 'sqlite3'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sass-rails', '>= 3.2'
gem 'coffee-rails'
gem 'uglifier', '>= 1.2.4'

group :test, :development do
  gem 'byebug', platform: :mri
  gem 'railroady'
  gem 'database_cleaner', '~> 1.3'
  gem 'factory_bot_rails', '~> 4.8'
  gem 'minitest-spec-rails', '~> 5.3.0'
  gem 'minitest-reporters', '~> 1.1.5'
end
