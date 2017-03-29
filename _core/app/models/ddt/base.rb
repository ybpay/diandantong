module Ddt
  class Base < ActiveRecord::Base
    include Ddt::TouchCacheVersion
    include Ddt::UnicodeFilter
    include Ddt::Preferences::Preferable
    include Ddt::SetFrom
    include Ddt::ActsAsType
    include Ddt::IdsString
    include Ddt::RecordStateChange
    include Ddt::ShopForeign
    include Ddt::ShopPhoneValid
    include Ddt::UrlFilter
    include Ddt::OrderService::Concern::OrderRelation
    #我们数据库通过配置utf8mb4已经支持emoji,如不支持，可配置支持。
    # include Ddt::EmojiModelHelper
    MAX_INTEGER = 2147483647
    MAX_DECIMAL = 99999999
    MAX_SP_ID = 9999

    serialize :preferences, Hash
    after_initialize do
      self.preferences = default_preferences.merge(preferences) if has_attribute?(:preferences)
    end

    self.abstract_class = true
    get_with_shop_time_zone :created_at, :updated_at

    def self.url_method_for(*names)
      names.each do |name|
        define_method "#{name}_url" do
          URI.join(Rails.application.routes.url_helpers.ddt_url, self.send("#{name}_path")).to_s
        end
      end
    end

    def self.retry_with_times(options={})
      tries = (options[:times] || 3)
      interval = (options[:interval] || 0)
      begin
        yield
      rescue => e
        Rails.logger.error "The #{(options[:times] || 3) - tries} times retry failed"
        if (tries -= 1) > 0
          sleep interval
          retry
        else
          Rails.logger.error options[:error_message] if options[:error_message]
          Rails.logger.error e.message
          raise
        end
      end
    end

    private
    def retry_with_times(options={}, &block)
      self.class.retry_with_times(options, &block)
    end
  end
end
