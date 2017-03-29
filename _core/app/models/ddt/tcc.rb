#encoding: utf-8
module Ddt
  # thread cache control
  module TCC
    class << self
      CACHE_NAME_PREFIX = 'tcc'
      def enable
        RequestStore.store["#{CACHE_NAME_PREFIX}.enable"] = true
      end

      def enable?
        RequestStore.store["#{CACHE_NAME_PREFIX}.enable"]
      end

      def disable
        RequestStore.store["#{CACHE_NAME_PREFIX}.enable"] = false
      end

      def clear
        RequestStore.store.keys.grep(/#{CACHE_NAME_PREFIX}\..+/).each do |key|
          RequestStore.store[key] = nil
        end
      end

      def fetch(key)
        # Rails.logger.info "==================#{key}======================="
        if enable?
          value = RequestStore.store["#{CACHE_NAME_PREFIX}.#{key}"]
          if !value.present? and block_given?
            value = RequestStore.store["#{CACHE_NAME_PREFIX}.#{key}"] = yield
          end
          value
        else
          # 如果不开启，且不给定块，则返回 nil
          yield if block_given?
        end
      end

      def write(key, value)
        RequestStore.store["#{CACHE_NAME_PREFIX}.#{key}"] = value
      end
    end
  end
end