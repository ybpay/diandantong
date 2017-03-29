# add since rails 4.1
module Ddt
  module Concerning
    extend ActiveSupport::Concern
    module ClassMethods
      def concerning(topic, &block)
        include concern(topic, &block)
      end

      def concern(topic, &module_definition)
        const_set topic, Module.new {
          extend ::ActiveSupport::Concern
          module_eval(&module_definition)
        }
      end
    end
  end
end