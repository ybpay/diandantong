module Ddt
  module TouchCacheVersion
    extend ActiveSupport::Concern

    module ClassMethods
      def touch_cache_version_of_scope(scope, cache_key=nil)
        self.class_eval do
          after_save :update_cache_version
          after_touch :update_cache_version
          after_destroy :update_cache_version
          define_method :update_cache_version do
            key = cache_key || self.class.name.underscore.pluralize
            cache_version = Ddt::CacheVersion.find_or_create_by(scope: self.send(scope.to_sym), key: key)
            cache_version.update_columns(updated_at: self.updated_at)
          end
        end
      end
    end

  end
end
