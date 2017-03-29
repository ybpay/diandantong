module Ddt
  class Role
    class Custom < Role
      def self.model_name
        ::Ddt::Role.model_name
      end
    end
  end
end