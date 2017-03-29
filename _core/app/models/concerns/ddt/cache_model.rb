module Ddt
  module CacheModel
    extend ActiveSupport::Concern

    module ClassMethods

      # options {with_deleted: true}
      def cache_model(class_name, options={})
        klass = class_name.constantize
        method_name = "get_#{class_name.demodulize.underscore}"
        model_cache_key = "_model_cache_#{class_name.demodulize.underscore}s"

        define_method method_name do |id|
          return nil if id.nil?
          TCC.fetch("#{model_cache_key}.#{id}") do
            if options[:with_deleted]
              obj = (klass.with_deleted.find(id) rescue nil)
            else
              obj = (klass.find(id) rescue nil)
            end
          end
        end
      end

    end

  end
end
