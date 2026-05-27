# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'

abort('Rails is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'factory_bot_rails'
require 'shoulda-matchers'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/config/'
  minimum_coverage 80
end

Dir[Rails.root.join('spec', '_support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = ['spec/fixtures']
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :request) do
    @shop = create(:shop_with_boss)
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
