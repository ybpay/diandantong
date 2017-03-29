module Ddt
  module Core
    class Environment
      include EnvironmentExtension

      attr_accessor :payment_methods, :shop, :branch

      def initialize
        @shop = Shop.new
        @branch = Branch.new
      end
    end
  end
end