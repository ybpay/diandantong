ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/reporters"
require 'sidekiq/testing'
require 'mocha/mini_test'
require 'support/lib/ddt/backtrace_filter'
require 'support/lib/ddt/engine_controller_test_route_patch'
require 'support/lib/ddt/request_json_helper'
require 'support/lib/ddt/test_case/base'
require 'support/lib/ddt/test_case/controller/base'
require 'support/lib/ddt/test_case/controller/weixin'
require 'support/lib/ddt/test_case/controller/webpos'
require 'support/lib/ddt/test_case/controller/backend'
require 'support/lib/ddt/test_case/controller/oauth_api'
require 'support/lib/ddt/test_case/controller/common_api'
# Dir[File.dirname(__FILE__) + "/support/lib/**/*.rb"].each {|file| require file }
Dir[File.dirname(__FILE__) + "/models/concerns/**/*.rb"].each {|file| require file }

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new, ENV, Ddt::BacktraceFilter.new)
DatabaseCleaner.strategy = :transaction
Sidekiq::Testing.fake! # fake! inline! disable!

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# init data
if Rails.env.test?
  if Ddt::Shop.count == 0
    puts "--------init test data--------"
    shop = FactoryGirl.create :shop_with_boss
    [:worker,:deliveryman,:cook,:chef,:waiter,:cashier,:vip_info_manager,:queue_waiter].each do |roll_name|
      FactoryGirl.create roll_name, shop: shop, manage_branches: shop.branches
    end
    Ddt::WeixinApi.stubs(:fetch_access_token).returns(true)
    wechat_account = FactoryGirl.create(:wechat_account, shop_id: shop.id)
    user = FactoryGirl.create(:user, shop_id: shop.id)
  end
end

# clear data
MiniTest.after_run do
  puts "--------after run clear data--------"
  ActiveRecord::Base.connection.tables.map{|t| t.classify.gsub("Ddt", "Ddt::")}
    .select{|t| t.start_with?("Ddt::") && Ddt.const_defined?(t.gsub("Ddt::", ""))}
    .map{|name| name.constantize}
    .compact.each(&:delete_all)
end

# 载入schema
# rake db:drop RAILS_ENV=test
# rake db:create RAILS_ENV=test
# rake db:schema:load RAILS_ENV=test

# run all tests : rake test
# run in folder : rake test:s test/models/
# run one test  : rake test test/models/sample_test.rb
# run one test  : ruby -Itest test/models/sample_test.rb

# factorygirl lint
# bundle exec rake factory_girl:lint RAILS_ENV='test'

# console
# rails c test

# stub mock example
# Product.expects(:find).with(1).returns(product)
# product.expects(:save).returns(true)
# prices = [stub(:pence => 1000), stub(:pence => 2000)]
# product.stubs(:prices).returns(prices)
# Product.any_instance.stubs(:name).returns('stubbed_name')
# object = mock('object')
# object.expects(:expected_method).with(:p1, :p2).returns(:result)
# object = stub(:method1 => :result1, :method2 => :result2)