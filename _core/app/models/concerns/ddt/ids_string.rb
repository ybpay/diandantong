module Ddt
  module IdsString
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def ids_string_for(*model_names)
        model_names.map(&:to_s).map(&:singularize).each do |name|
          define_method "#{name}_ids_string" do
            
            self.send("#{name}_ids").join(',')
          end
          define_method "#{name}_ids_string=" do |s|
            self.send("#{name}_ids=", s.to_s.split(',').map(&:strip))
          end
        end
      end
    end

  end
end