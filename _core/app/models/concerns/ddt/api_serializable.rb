module Ddt
  module ApiSerializable
    extend ActiveSupport::Concern

    class_methods do
      def api_attributes(*attrs)
        @api_attributes = attrs if attrs.any?
        @api_attributes || []
      end
    end

    def as_api_json
      attrs = self.class.api_attributes
      if attrs.any?
        attrs.each_with_object({}) do |attr, hash|
          hash[attr] = send(attr)
        end
      else
        serializable_hash(except: %w[deleted_at discarded_at]).compact
      end
    end
  end
end
