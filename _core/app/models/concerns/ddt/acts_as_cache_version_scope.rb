module Ddt
  module ActsAsCacheVersionScope
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_cache_version_scope_of(*keys)
        keys.each do |key|
          define_method "#{key.to_s.pluralize}_cache_version".to_sym do
            cache_key = "ddt/#{key.to_s.pluralize}"
            cache_version = Ddt::CacheVersion.find_or_create_by(scope: self, key: cache_key)
            if cache_version.updated_at.present?
              if cache_version.updated_at.today?
                cache_version.version
              else
                Time.now.beginning_of_day.to_i * 1000
              end
            else
              cache_version.touch
              cache_version.version
            end
          end
        end
      end
    end
  end
end
