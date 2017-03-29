module Ddt
  module Backend
    module TempAttribute
      extend ActiveSupport::Concern
      def add_temp_attributes(obj, *tmp_attrs)
        tmp_attrs.each do |tmp_attr|
          obj.define_singleton_method tmp_attr do
            obj.instance_variable_get "@#{tmp_attr}".to_sym
          end

          obj.define_singleton_method "#{tmp_attr}=" do |value|
            obj.instance_variable_set "@#{tmp_attr}".to_sym, value
          end
        end
      end
    end
  end
end
