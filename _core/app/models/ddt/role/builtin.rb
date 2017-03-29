module Ddt
  class Role
    module Builtin
      extend ActiveSupport::Concern
      included do
        def self.model_name
          ::Ddt::Role.model_name
        end
      end
    end
  end
end