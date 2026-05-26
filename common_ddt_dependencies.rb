source 'https://gems.ruby-china.com'

gem 'rails', "~> 8.1.0"
gem 'mysql2', '>= 0.5.4'
gem 'sqlite3'
gem 'puma', '~> 7.0'
gem 'jbuilder', '~> 2.7'

group :test, :development do
  gem 'byebug', platform: :mri
  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'minitest-spec-rails', '~> 5.3.0'
  gem 'minitest-reporters', '~> 1.1.5'
end
