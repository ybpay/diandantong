module Ddt
  module Core
    class Environment
      class Shop
        include EnvironmentExtension
        attr_accessor :calculators
        def initialize
          @calculators = ::Ddt::Core::Environment::Calculators.new
        end
      end
    end
  end
end