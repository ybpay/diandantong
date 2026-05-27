# frozen_string_literal: true

module Ddt
  class Base < ApplicationRecord
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

    MAX_INTEGER = 2147483647
    MAX_DECIMAL = 99999999
    MAX_SP_ID = 9999

    serialize :preferences, coder: JSON
    after_initialize do
      self.preferences = default_preferences.merge(preferences) if has_attribute?(:preferences)
    end

    self.abstract_class = true

    def self.url_method_for(*names)
      names.each do |name|
        define_method "#{name}_url" do
          URI.join(Rails.application.routes.url_helpers.ddt_url, send("#{name}_path")).to_s
        end
      end
    end

    def self.retry_with_times(options = {})
      tries = (options[:times] || 3)
      interval = (options[:interval] || 0)
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

    private

    def retry_with_times(options = {}, &block)
      self.class.retry_with_times(options, &block)
    end
  end
end
